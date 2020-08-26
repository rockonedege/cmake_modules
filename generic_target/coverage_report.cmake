# Provides function to generate coverage reports.
#
# The following function will be provided:
#     register_for_coverage_report - create custom targets to generate coverage reports

include_guard(GLOBAL)

#[[

Helper function to create custom targets to generate coverage reports for a given target.

register_for_coverage_report(TARGET <target>
                             [ADDITIONAL_ARGUMENTS <argument>...]
                             [ADDITIONAL_OBJECTS <object>...]
                             [EXCLUDE_REGEXES <regex>...]
)

This function requires that the build type is set to 'Coverage' and that the compiler
is 'Clang' as otherwise the required compiler flags and tools don't work.

The coverage report is based on https://clang.llvm.org/docs/SourceBasedCodeCoverage.html and
for the generation the LLVM tools 'llvm-cov' and 'llvm-profdata' are required.

The following custom targets will be available and should be used:
    - coverage_report: generate HTML reports for all registered targets
    - coverage_report-<target>: generate a HTML report for the specific target

NOTE: Some other custom targets will be created but they should not be called directly.

- TARGET
Target which should be registered.
NOTE: Target needs to be of type 'Executable'.

- ADDITIONAL_ARGUMENTS
List of command line arguments which should be used when calling the target binary.
NOTE: Arguments with a whitespace needed to be either splitted as separate entries
      or need to be separated with a semicolon.

- ADDITIONAL_OBJECTS
List of additional objects (object file, dynamic library, or archive) from which coverage
is desired. The main usage would be when the project target is a library and coverage
is wanted for a test binary which links against the library.

- EXCLUDE_REGEXES
List of regexes which define the source code files/directories which should be filtered out
from the coverage report.
NOTE: When this option is given the coverage report directory contains 2 folder.
      - 'filtered' which contains the report with the regexes used.
      - 'full' which contains the whole report without an exclusion.

#]]
function(register_for_coverage_report)
    # define arguments for cmake_parse_arguments
    list(APPEND one_value_args
        TARGET
    )
    list(APPEND multi_value_args
        ADDITIONAL_ARGUMENTS
        ADDITIONAL_OBJECTS
        EXCLUDE_REGEXES
    )

    # use cmake helper function to parse passed arguments
    cmake_parse_arguments(
        cov
        ""
        "${one_value_args}"
        "${multi_value_args}"
        ${ARGN}
    )

    # check if the calling project is not the root project
    if(NOT PROJECT_NAME STREQUAL CMAKE_PROJECT_NAME)
        # do not create targets when the caller is not the root project
        return()
    endif()

    # check for required arguments
    if(NOT DEFINED cov_TARGET)
        message(FATAL_ERROR "TARGET argument required!")
    else()
        get_target_property(${cov_TARGET}_type ${cov_TARGET} TYPE)
        if(NOT ${cov_TARGET}_type MATCHES "EXECUTABLE")
            message(FATAL_ERROR "${cov_TARGET} is not an executable!")
        endif()
    endif()

    set(no_targets_message "Targets to generate coverage reports will not be available!")

    # check for some general requirements
    if(NOT CMAKE_BUILD_TYPE MATCHES "Coverage")
        message(STATUS "Build type is not 'Coverage' which is needed to generate coverage reports.")
        message(STATUS "${no_targets_message}")

        return()
    endif()

    if((NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        AND (NOT "${CMAKE_C_COMPILER_ID}" STREQUAL "Clang"))

        message(STATUS "Coverage reports can only be generated when the Clang compiler is used.")
        message(STATUS "${no_targets_message}")

        return()
    endif()

    # check for tools which are needed to generate coverage reports
    if((NOT DEFINED llvm_cov_executable)
        OR (NOT DEFINED llvm_cxxfilt_executable)
        OR (NOT DEFINED llvm_profdata_executable))
        find_program(llvm_cov_executable NAMES "llvm-cov")
        find_program(llvm_cxxfilt_executable NAMES "llvm-cxxfilt")
        find_program(llvm_profdata_executable NAMES "llvm-profdata")

        mark_as_advanced(FORCE
            llvm_cov_executable
            llvm_cxxfilt_executable
            llvm_profdata_executable
        )

        if((NOT llvm_cov_executable) OR (NOT llvm_profdata_executable))
            set(line_one "Unable to find required tools to generate coverage reports:")
            set(line_two "llvm-cov: ${llvm_cov_executable}")
            set(line_three "llvm-profdata: ${llvm_profdata_executable}")
            set(line_four "llvm-cxxfilt (optional): ${llvm_cxxfilt_executable}")

            string(CONCAT whole_message
                "${line_one}\n"
                "${line_two}\n"
                "${line_three}\n"
                "${line_four}"
            )

            message(WARNING "${whole_message}")
            message(STATUS "${no_targets_message}")

            return()
        else()
            message(DEBUG "Found llvm-cov: ${llvm_cov_executable}")
            message(DEBUG "Found llvm-profdata: ${llvm_profdata_executable}")
            if(llvm_cxxfilt_executable)
                message(DEBUG "Found llvm-cxxfilt: ${llvm_cxxfilt_executable}")
            endif()
        endif()
    endif()

    # define variables which hold target names which are used below
    set(coverage_report_all_target "coverage_report")
    set(coverage_report_specific_target "${coverage_report_all_target}-${cov_TARGET}")
    # internal targets which should not be called directly
    set(coverage_setup_target "coverage_setup")
    set(coverage_cleanup_target "coverage_cleanup")
    set(coverage_run_target "coverage_run-${cov_TARGET}")
    set(coverage_processing_target "coverage_processing-${cov_TARGET}")

    set(coverage_working_dir "${CMAKE_CURRENT_BINARY_DIR}/.tmp_coverage")

    # some general targets to not pollute the build directory
    if(NOT TARGET ${coverage_setup_target})
        add_custom_target(${coverage_setup_target}
            COMMAND
                ${CMAKE_COMMAND} -E make_directory ${coverage_working_dir}
            DEPENDS
                ${coverage_cleanup_target}
        )
    endif()

    if(NOT TARGET ${coverage_cleanup_target})
        add_custom_target(${coverage_cleanup_target}
            COMMAND
                ${CMAKE_COMMAND} -E rm -rf ${coverage_working_dir}
        )
    endif()

    set(coverage_raw_file "${coverage_working_dir}/${cov_TARGET}.profraw")
    set(coverage_data_file "${coverage_working_dir}/${cov_TARGET}.profdata")

    # the 'exit 0' is needed to get a coverage report even
    # if the executable ended with an error code e.g. failed test
    add_custom_target(${coverage_run_target}
        COMMAND
            LLVM_PROFILE_FILE=${coverage_raw_file}
            $<TARGET_FILE:${cov_TARGET}> ${cov_ADDITIONAL_ARGUMENTS} || exit 0
        BYPRODUCTS
            ${coverage_raw_file}
        DEPENDS
            ${coverage_setup_target}
    )

    add_custom_target(${coverage_processing_target}
        COMMAND
            ${llvm_profdata_executable} merge -sparse ${coverage_raw_file} -o ${coverage_data_file}
        BYPRODUCTS
            ${coverage_data_file}
        DEPENDS
            ${coverage_run_target}
    )

    if(llvm_cxxfilt_executable)
        # NOTE: the semicolon will result in a 'whitespace' (splitted arguments)
        set(demangler_argument "-Xdemangler;${llvm_cxxfilt_executable}")
    else()
        set(demangler_argument "")
    endif()

    # iterate over the input lists to generate the corresponding command line arguments
    foreach(object IN LISTS cov_ADDITIONAL_OBJECTS)
        list(APPEND additional_objects_argument
            "-object=${object}"
        )
    endforeach()

    list(LENGTH cov_EXCLUDE_REGEXES regex_list_length)
    if(regex_list_length EQUAL 0)
        add_custom_target(${coverage_report_specific_target}
            COMMAND
                ${llvm_cov_executable} show $<TARGET_FILE:${cov_TARGET}>
                -object=$<TARGET_FILE:${cov_TARGET}>
                ${additional_objects_argument}
                -instr-profile=${coverage_data_file}
                -show-line-counts-or-regions
                -output-dir=coverage-${cov_TARGET}
                -format="html"
                ${demangler_argument}
            BYPRODUCTS
                coverage-${cov_TARGET}
            DEPENDS
                ${coverage_processing_target}
        )
    else()
        foreach(regex IN LISTS cov_EXCLUDE_REGEXES)
            list(APPEND ignore_regex_argument
                "-ignore-filename-regex=${regex}"
            )
        endforeach()

        add_custom_target(${coverage_report_specific_target}
            COMMAND
                ${llvm_cov_executable} show $<TARGET_FILE:${cov_TARGET}>
                -object=$<TARGET_FILE:${cov_TARGET}>
                ${additional_objects_argument}
                -instr-profile=${coverage_data_file}
                -show-line-counts-or-regions
                -output-dir=coverage-${cov_TARGET}/full
                -format="html"
                ${demangler_argument}
           COMMAND
                ${llvm_cov_executable} show $<TARGET_FILE:${cov_TARGET}>
                -object=$<TARGET_FILE:${cov_TARGET}>
                ${additional_objects_argument}
                -instr-profile=${coverage_data_file}
                -show-line-counts-or-regions
                -output-dir=coverage-${cov_TARGET}/filtered
                -format="html"
                ${demangler_argument}
                ${ignore_regex_argument}
            BYPRODUCTS
                coverage-${cov_TARGET}
            DEPENDS
                ${coverage_processing_target}
        )
    endif()

    # 'all' target which can be used to generate coverage reports for all registered targets
    if(NOT TARGET ${coverage_report_all_target})
        add_custom_target(${coverage_report_all_target})
    endif()

    add_dependencies(${coverage_report_all_target} ${coverage_report_specific_target})
endfunction()
