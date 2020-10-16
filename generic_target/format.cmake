# The following functions will be provided:
#   - define_format_targets

include_guard(GLOBAL)

#[[

Helper function which defines formatting related generic targets.

define_format_targets()

The following target be will defined:
    - 'format': runs clang-format against all C and C++ files and changes them in place
    - 'check_format': runs clang-format in dry run mode to see if the code is correctly formatted

#]]
function(define_format_targets)
    # check if the calling project is not the root project
    if(NOT PROJECT_NAME STREQUAL CMAKE_PROJECT_NAME)
        # do not create targets when the caller is not the root project
        return()
    endif()

    set(no_targets_message "Formatting related targets will not be available!")

    # search for required programs (clang-format / git)
    if(NOT DEFINED clang_format_executable)
        find_program(clang_format_executable NAMES "clang-format")

        mark_as_advanced(FORCE
            clang_format_executable
        )

        if(NOT clang_format_executable)
            message(WARNING "clang-format was not found!")
            message(WARNING "${no_targets_message}")
            return()
        else()
            # get the clang-format version string
            execute_process(
                COMMAND
                    ${clang_format_executable} --version
                OUTPUT_VARIABLE
                    clang_format_version
                ERROR_QUIET
                OUTPUT_STRIP_TRAILING_WHITESPACE
            )

            # only get the version part of the process output
            string(REGEX MATCH "[0-9\.]+" clang_format_version "${clang_format_version}")

            # cache the version number
            set(clang_format_version "${clang_format_version}" CACHE STRING "clang-format version")
            mark_as_advanced(FORCE clang_format_version)

            message(DEBUG "Found clang-format: ${clang_format_executable} ${clang_format_version}")
        endif()
    endif()

    if(NOT DEFINED GIT_EXECUTABLE)
        # check if git is available
        find_package(Git QUIET)

        if(NOT Git_FOUND)
            message(WARNING "git was not found!")
            message(WARNING "${no_targets_message}")
            return()
        else()
            message(DEBUG "Found git: ${GIT_EXECUTABLE}")
        endif()
    endif()

    # get a list of all cached (+ deleted) and untracked git repository files
    execute_process(
        COMMAND
            ${GIT_EXECUTABLE} ls-files --cached --others --exclude-standard
        WORKING_DIRECTORY
            ${PROJECT_SOURCE_DIR}
        OUTPUT_VARIABLE
            file_list
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # get a list of all delete git repository files
    execute_process(
        COMMAND
            ${GIT_EXECUTABLE} ls-files --deleted --exclude-standard
        WORKING_DIRECTORY
            ${PROJECT_SOURCE_DIR}
        OUTPUT_VARIABLE
            deleted_file_list
        ERROR_QUIET
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # convert output variables to a real CMake list
    string(REPLACE "\n" ";" file_list "${file_list}")
    string(REPLACE "\n" ";" deleted_file_list "${deleted_file_list}")

    # remove all deleted file entries from the file list
    foreach(item IN LISTS deleted_file_list)
        list(REMOVE_ITEM file_list ${item})
    endforeach()

    # only include C and C++ related files in the list
    list(FILTER file_list INCLUDE REGEX "^.*\\.(cpp|hpp|cxx|hxx|cc|hh|c|h)$")
    # update entries to contain the full absolute path
    list(TRANSFORM file_list PREPEND "${PROJECT_SOURCE_DIR}/")

    # only check if the files need to be formatted but do not change them
    if("${clang_format_version}" VERSION_GREATER_EQUAL "10")
        add_custom_target(check_format
            COMMAND
                ${clang_format_executable} --dry-run --Werror --style=file ${file_list}
            WORKING_DIRECTORY
                ${PROJECT_SOURCE_DIR}
            COMMAND_EXPAND_LISTS
        )
    else()
        message(STATUS "clang-format version < 10, 'check_format' target will not be available!")
    endif()

    # format the files in place
    add_custom_target(format
        COMMAND
            ${clang_format_executable} -i --style=file ${file_list}
        WORKING_DIRECTORY
            ${PROJECT_SOURCE_DIR}
        COMMAND_EXPAND_LISTS
    )
endfunction()
