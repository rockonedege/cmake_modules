# Provides function to register target to cppcheck.
#
# The following function will be provided:
#     register_for_cppcheck - set cppcheck property of target

include_guard(GLOBAL)

#[[

Helper function to set the 'C_CPPCHECK' and 'CXX_CPPCHECK' property of the given target.

register_for_cppcheck(<target>)

The following cache variables will be set/provided:
    <project-name>_use_cppcheck - True if cppcheck was found.

#]]
function(register_for_cppcheck target)
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

        mark_as_advanced(FORCE cppcheck_executable)
    endif()

    # just in case check here again if the cppcheck executable is defined
    if(${PROJECT_NAME}_use_cppcheck AND DEFINED cppcheck_executable)
        list(APPEND cppcheck_command
            ${cppcheck_executable}
            --enable=warning,performance,portability,style,information
            --template=gcc
            --suppress=syntaxError
            --suppress=passedByValue
            --suppress=missingInclude
            --suppress=unusedStructMember
            --suppress=unmatchedSuppression
            --suppress=missingIncludeSystem
            --suppress=ConfigurationNotChecked
            --quiet
        )

        set_target_properties(${target}
            PROPERTIES
                C_CPPCHECK "${cppcheck_command}"
                CXX_CPPCHECK "${cppcheck_command}"
        )
    endif()
endfunction()
