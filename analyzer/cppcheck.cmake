# Provides function to register target to cppcheck.
#
# The following function will be provided:
#     register_for_cppcheck - add pre build cppcheck step to target

include_guard(GLOBAL)

#[[

Helper function to create pre build step to run cppcheck for the given target.

register_for_cppcheck(TARGET <target>
                      [C_STANDARD|CXX_STANDARD <version>]
)

- TARGET
Target which should be configured.

- C_STANDARD
C standard which should be used.

- CXX_STANDARD
C++ standard which should be used.

The following cache variables will be set/provided:
    <project-name>_use_cppcheck - True if cppcheck was found.

NOTE: The target needs to have the 'SOURCES' and 'INCLUDE_DIRECTORIES' properties set.

#]]
function(register_for_cppcheck)
    # define arguments for cmake_parse_arguments
    list(APPEND one_value_args
        TARGET
        C_STANDARD
        CXX_STANDARD
    )

    # use cmake helper function to parse passed arguments
    cmake_parse_arguments(
        tpre
        ""
        "${one_value_args}"
        ""
        ${ARGN}
    )

    # check for required arguments
    if(NOT DEFINED tpre_TARGET)
        message(FATAL_ERROR "TARGET argument required!")
    endif()

    # check for XOR arguments
    if(DEFINED tpre_C_STANDARD AND DEFINED tpre_CXX_STANDARD)
        message(FATAL_ERROR "Defining C_STANDARD and CXX_STANDARD is not allowed!")
    endif()

    # define cache variable which can be used to toggle the usage
    set(${PROJECT_NAME}_use_cppcheck ON
        CACHE
            BOOL "cppcheck will be used"
    )

    # if the cppcheck executable is not defined and the user wants to use cppcheck
    if(NOT DEFINED cppcheck_executable AND ${PROJECT_NAME}_use_cppcheck)
        # search for 'cppcheck' executable
        find_program(cppcheck_executable NAMES "cppcheck")

        if(NOT cppcheck_executable)
            message(WARNING "cppcheck was not found!")
            message(WARNING "Calling 'register_for_cppcheck' will not have an effect.")

            # force set the cache variable to new value
            set(${PROJECT_NAME}_use_cppcheck OFF
                CACHE
                    BOOL "cppcheck will be used"
                FORCE
            )
        else()
            message(DEBUG "Found cppcheck: ${cppcheck_executable}")
        endif()
    endif()

    # just in case check here again if the cppcheck executable is defined
    if(${PROJECT_NAME}_use_cppcheck AND DEFINED cppcheck_executable)
        get_target_property(sources ${tpre_TARGET} SOURCES)
        get_target_property(include_dirs ${tpre_TARGET} INCLUDE_DIRECTORIES)

        # don't check against .ui files from Qt
        list(FILTER sources EXCLUDE REGEX ".*(ui)")

        # iterate over the 'include_dirs' and add '-I' in front of each directory
        set(include_dirs_as_parameter)
        foreach(include_dir ${include_dirs})
            list(APPEND include_dirs_as_parameter "-I${include_dir}")
        endforeach()

        # if the project is build with Qt, the auto generated include directory should be added
        if(${${PROJECT_NAME}_with_qt})
            list(APPEND include_dirs_as_parameter
                "-I${CMAKE_CURRENT_BINARY_DIR}/${tpre_TARGET}_autogen/include"
            )
        endif()

        # define cppcheck language specific commandline flags
        set(language_specific_flags)
        if(DEFINED tpre_C_STANDARD)
            list(APPEND language_specific_flags
                --language=c
                --std=c${tpre_C_STANDARD}
            )
        elseif(DEFINED tpre_CXX_STANDARD)
            list(APPEND language_specific_flags
                --language=c++
                --std=c++${tpre_CXX_STANDARD}
            )
        endif()

        add_custom_command(
            TARGET
                ${tpre_TARGET}
            PRE_BUILD
                COMMENT "[----] Running cppcheck on target: ${tpre_TARGET}"
            COMMAND
                ${cppcheck_executable}
                ${language_specific_flags}
                --platform=native
                --enable=warning,performance,portability,style,information
                --template=gcc
                --suppress=syntaxError
                --suppress=passedByValue
                --suppress=missingInclude
                --suppress=unusedStructMember
                --suppress=unmatchedSuppression
                --suppress=missingIncludeSystem
                --suppress=ConfigurationNotChecked
                -i "${CMAKE_CURRENT_BINARY_DIR}/${tpre_TARGET}_autogen"
                --quiet
                ${include_dirs_as_parameter}
                ${sources}
        )
    endif()
endfunction()
