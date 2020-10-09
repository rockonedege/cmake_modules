# The following functions will be provided:
#   - get_git_revision_description

include_guard(GLOBAL)

#[[

Get the current git revision.

get_git_revision_description(<var>)

- <var>
Stores the resulting git revision in the given variable.
The content of the given variable will be completely overridden.

The following cache variables will be set/provided:
    <project-name>_get_git_status - True if Git was found.

#]]
function(get_git_revision_description output_var)
    # define cache variable
    set(${PROJECT_NAME}_get_git_status ON
        CACHE
            BOOL "Get current git status"
    )

    # if the git executable is not defined and the user wants the git status
    if(NOT DEFINED GIT_EXECUTABLE AND ${PROJECT_NAME}_get_git_status)
        # check if git is available
        find_package(Git QUIET)

        if(NOT Git_FOUND)
            message(WARNING "git was not found!")
            message(WARNING "Calling '${CMAKE_CURRENT_FUNCTION}' will not have an effect.")

            # force set the cache variable to new value
            set(${PROJECT_NAME}_get_git_status OFF
                CACHE
                    BOOL "Get current git status"
                FORCE
            )
        else()
            message(DEBUG "Found git: ${GIT_EXECUTABLE}")
        endif()
    endif()

    # just in case check here again if the git executable is defined
    if(${PROJECT_NAME}_get_git_status AND DEFINED GIT_EXECUTABLE)
        # get the commit id
        execute_process(
            COMMAND
                "${GIT_EXECUTABLE}" rev-parse --short HEAD
            WORKING_DIRECTORY
                "${PROJECT_SOURCE_DIR}"
            OUTPUT_VARIABLE
                git_commit_id
            ERROR_QUIET
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )

        # this leads to project re-configuration if
        # a commit changes (add/revert/etc.)
        set_property(DIRECTORY APPEND
            PROPERTY
                CMAKE_CONFIGURE_DEPENDS
                    "${PROJECT_SOURCE_DIR}/.git/index"
                    "${PROJECT_SOURCE_DIR}/.git/logs/HEAD"
        )
        set(${output_var} ${git_commit_id} PARENT_SCOPE)
    endif()
endfunction()
