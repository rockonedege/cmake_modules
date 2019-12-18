# Provides function to get the current git revision.
#
# The following cache variables will be set/provided:
#     <project-name>_get_git_status - True if Git was found.
#
# The following function will be provided:
#     get_git_revision_description - provides the current git revision

include_guard(GLOBAL)

# check if git is available
find_package(Git QUIET)

# define option for usage
set(${PROJECT_NAME}_get_git_status OFF
    CACHE
        BOOL "Get current git status"
    FORCE
)

if(NOT Git_FOUND)
    message(WARNING "git was not found!")
    message(WARNING "Calling 'get_git_revision_description' will not have an effect.")
else()
    set(${PROJECT_NAME}_get_git_status ON
        CACHE
            BOOL "Get current git status"
        FORCE
    )

    message(STATUS "Found git: ${GIT_EXECUTABLE}")
endif()

#[[

Get the current git revision.

get_git_revision_description(<var>)

- <var>
Stores the resulting git revision in the given variable.
The content of the given variable will be completely overridden.

#]]
function(get_git_revision_description output_var)
    if(GET_GIT_STATUS)
        # get the commit id
        execute_process(
            COMMAND
                "${GIT_EXECUTABLE}" rev-parse --short HEAD
            WORKING_DIRECTORY
                "${CMAKE_SOURCE_DIR}"
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
                    "${CMAKE_SOURCE_DIR}/.git/index"
                    "${CMAKE_SOURCE_DIR}/.git/logs/HEAD"
        )
        set(${output_var} ${git_commit_id} PARENT_SCOPE)
    endif()
endfunction()
