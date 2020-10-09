# The following functions will be provided:
#   - update_git_submodule

include_guard(GLOBAL)

#[[

Update and initialize the submodule for the provided path recursively.

update_git_submodule(<path-to-submodule>)

- <path-to-submodule>
Path to the submodule which should be used for the `git submodule` call.

#]]
function(update_git_submodule path_to_submodule)
    # error messages which are used at multiple positions
    set(no_effect_message "Calling '${CMAKE_CURRENT_FUNCTION}' will not have an effect.")
    set(git_call_failed_message "'git submodule' call failed, please checkout submodules manually!")

    # check that the project is a Git repository
    if(NOT EXISTS "${PROJECT_SOURCE_DIR}/.git")
        message(WARNING "${PROJECT_SOURCE_DIR} is not a Git repository!")
        message(WARNING "${no_effect_message}")
        return()
    endif()

    # if the git executable is not defined search for it
    if(NOT DEFINED GIT_EXECUTABLE)
        find_package(Git QUIET)

        if(NOT Git_FOUND)
            message(WARNING "git was not found!")
            message(WARNING "${no_effect_message}")
            return()
        else()
            message(DEBUG "Found git: ${GIT_EXECUTABLE}")
        endif()
    endif()

    execute_process(
        COMMAND
            ${GIT_EXECUTABLE} submodule update --init --recursive ${path_to_submodule}
        WORKING_DIRECTORY
            ${PROJECT_SOURCE_DIR}
        ERROR_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE
            git_process_call_error
        RESULT_VARIABLE
            git_process_call_result
    )

    if(NOT git_process_call_result EQUAL "0")
        message(STATUS "Git process result: ${git_process_call_result}")
        message(STATUS "${git_process_call_error}")
        message(FATAL_ERROR "${git_call_failed_message}")
    endif()

    if(NOT EXISTS "${path_to_submodule}/.git")
        message(FATAL_ERROR "${git_call_failed_message}")
    endif()
endfunction()
