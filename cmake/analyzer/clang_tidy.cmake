# Provides function to register target to clang-tidy.
#
# The following cache variables will be set/provided:
#     <project-name>_use_clang_tidy - True if clang-tidy was found.
#
# The following function will be provided:
#     register_for_clang_tidy - set clang-tidy property of target

include_guard(GLOBAL)

# search for 'clang-tidy' executable
find_program(clang_tidy_executable NAMES "clang-tidy")

# define cache variable which can be used to toggle the usage
set(${PROJECT_NAME}_use_clang_tidy OFF
    CACHE
        BOOL "clang-tidy will be used"
    FORCE
)

if(NOT clang_tidy_executable)
    message(WARNING "clang-tidy was not found!")
    message(WARNING "Calling 'register_for_clang_tidy' will not have an effect.")
else()
    set(${PROJECT_NAME}_use_clang_tidy ON
        CACHE
            BOOL "clang-tidy will be used"
        FORCE
    )

    message(STATUS "Found clang-tidy: ${clang_tidy_executable}")
endif()

#[[

Helper function to set the 'C_CLANG_TIDY' and 'CXX_CLANG_TIDY' property of the given target.

register_for_clang_tidy(<target>)

#]]
function(register_for_clang_tidy target_name)
    if(${PROJECT_NAME}_use_clang_tidy)

        list(APPEND clang_tidy_command
            "${clang_tidy_executable}"
            "-header-filter=${CMAKE_CURRENT_SOURCE_DIR}/.*"
            "-p=${CMAKE_CURRENT_BINARY_DIR}"
        )

        set_target_properties(${target_name}
            PROPERTIES
                C_CLANG_TIDY "${clang_tidy_command}"
                CXX_CLANG_TIDY "${clang_tidy_command}"
        )
    endif()
endfunction()
