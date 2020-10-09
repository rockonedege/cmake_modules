# The following functions will be provided:
#   - register_for_clang_tidy

include_guard(GLOBAL)

#[[

Helper function to set the 'C_CLANG_TIDY' and 'CXX_CLANG_TIDY' property of the given target.

register_for_clang_tidy(<target>)

The following cache variables will be set/provided:
    <project-name>_use_clang_tidy - True if clang-tidy was found.

#]]
function(register_for_clang_tidy target)
    # define cache variable which can be used to toggle the usage
    set(${PROJECT_NAME}_use_clang_tidy ON
        CACHE
            BOOL "clang-tidy will be used"
    )

    # if the clang-tidy executable is not defined and the user wants to use clang-tidy
    if(NOT DEFINED clang_tidy_executable AND ${PROJECT_NAME}_use_clang_tidy)
        # search for 'clang-tidy' executable
        find_program(clang_tidy_executable NAMES "clang-tidy")

        if(NOT clang_tidy_executable)
            message(WARNING "clang-tidy was not found!")
            message(WARNING "Calling '${CMAKE_CURRENT_FUNCTION}' will not have an effect.")

            # force set the cache variable to new value
            set(${PROJECT_NAME}_use_clang_tidy OFF
                CACHE
                    BOOL "clang-tidy will be used"
                FORCE
            )
        else()
            message(DEBUG "Found clang-tidy: ${clang_tidy_executable}")
        endif()

        mark_as_advanced(FORCE clang_tidy_executable)
    endif()

    # just in case check here again if the clang-tidy executable is defined
    if(${PROJECT_NAME}_use_clang_tidy AND DEFINED clang_tidy_executable)
        list(APPEND clang_tidy_command
            ${clang_tidy_executable}
            -header-filter=${CMAKE_CURRENT_SOURCE_DIR}/.*
            -p=${CMAKE_CURRENT_BINARY_DIR}
        )

        set_target_properties(${target}
            PROPERTIES
                C_CLANG_TIDY "${clang_tidy_command}"
                CXX_CLANG_TIDY "${clang_tidy_command}"
        )
    endif()
endfunction()
