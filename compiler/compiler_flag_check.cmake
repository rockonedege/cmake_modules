# The following functions will be provided:
#   - check_supported_cxx_compiler_flags
#   - check_supported_c_compiler_flags

include_guard(GLOBAL)

#[[

Check if the given compiler flags are supported by the current compiler.

check_supported_cxx_compiler_flags(<compiler-flags> <supported-compiler-flags>)

- <compiler-flags>
List of compiler flags which should be checked.

- <supported-compiler-flags>
Stores the resulting supported compiler flags as list in the given variable.
The content of the given variable will be completely overridden.

The following cache variables will be set/provided:
    <project-name>_force_cxx_compiler_flag_check - Set to ON to invalidate cache and check again.
                                                   Variable will be always set for OFF after call.

#]]
function(check_supported_cxx_compiler_flags compiler_flags supported_compiler_flags)
    if((NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        AND (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang"))
        message(WARNING "Compiler (${CMAKE_CXX_COMPILER_ID}) not supported!")
        return()
    endif()

    # define cache variable
    set(${PROJECT_NAME}_force_cxx_compiler_flag_check OFF
        CACHE
            BOOL "Invalidate cache and check compiler flags again. Always set to OFF after call."
    )

    if(${PROJECT_NAME}_force_cxx_compiler_flag_check
       OR (NOT ${PROJECT_NAME}_cached_cxx_compiler_flags))
        # get the helper function from cmake
        include(CheckCXXCompilerFlag)

        foreach(flag IN LISTS compiler_flags)
            # create variable used for cmake cache entry
            string(TOUPPER ${flag} cache_entry_flag_name)

            string(
                REGEX REPLACE
                    "^-W|^-" "CXX_FLAG_"
                cache_entry_flag_name
                ${cache_entry_flag_name}
            )

            string(
                REGEX REPLACE
                    "[-=]" "_"
                cache_entry_flag_name
                ${cache_entry_flag_name}
            )

            # call module function which does the actual check
            check_cxx_compiler_flag(${flag} ${cache_entry_flag_name})

            # NOTE: positive result indicates only that the compiler
            #       did not issue a diagnostic message with the flag
            if(${cache_entry_flag_name})
                list(APPEND internal_supported_flags ${flag})
            endif()

            # unset cache to always check on cmake run
            unset(${cache_entry_flag_name} CACHE)
        endforeach()

        # invalidate cached results and update with new results
        unset(${PROJECT_NAME}_cached_cxx_compiler_flags CACHE)
        set(
            ${PROJECT_NAME}_cached_cxx_compiler_flags
                "${internal_supported_flags}"
            CACHE
                INTERNAL ""
        )

       set(${PROJECT_NAME}_force_cxx_compiler_flag_check OFF
            CACHE
                BOOL "Invalidate cache and check compiler flags again. Set to OFF after call."
            FORCE
        )
    endif()

    # return cached result of compiler flags check
    set(${supported_compiler_flags}
        ${${PROJECT_NAME}_cached_cxx_compiler_flags}
        PARENT_SCOPE
    )
endfunction()

#[[

Check if the given compiler flags are supported by the current compiler.

check_supported_c_compiler_flags(<compiler-flags> <supported-compiler-flags>)

- <compiler-flags>
List of compiler flags which should be checked.

- <supported-compiler-flags>
Stores the resulting supported compiler flags as list in the given variable.
The content of the given variable will be completely overridden.

The following cache variables will be set/provided:
    <project-name>_force_c_compiler_flag_check - Set to ON to invalidate cache and check again.
                                                 Variable will be always set for OFF after call.

#]]
function(check_supported_c_compiler_flags compiler_flags supported_compiler_flags)
    if((NOT "${CMAKE_C_COMPILER_ID}" STREQUAL "GNU")
        AND (NOT "${CMAKE_C_COMPILER_ID}" STREQUAL "Clang"))
        message(WARNING "Compiler (${CMAKE_C_COMPILER_ID}) not supported!")
        return()
    endif()

    # define cache variable
    set(${PROJECT_NAME}_force_c_compiler_flag_check OFF
        CACHE
            BOOL "Invalidate cache and check compiler flags again. Set to OFF after call."
    )

    if(${PROJECT_NAME}_force_c_compiler_flag_check
       OR (NOT ${PROJECT_NAME}_cached_c_compiler_flags))
        # get the helper function from cmake
        include(CheckCCompilerFlag)

        foreach(flag IN LISTS compiler_flags)
            # create variable used for cmake cache entry
            string(TOUPPER ${flag} cache_entry_flag_name)

            string(
                REGEX REPLACE
                    "^-W|^-" "C_FLAG_"
                cache_entry_flag_name
                ${cache_entry_flag_name}
            )

            string(
                REGEX REPLACE
                    "[-=]" "_"
                cache_entry_flag_name
                ${cache_entry_flag_name}
            )

            # call module function which does the actual check
            check_c_compiler_flag(${flag} ${cache_entry_flag_name})

            # NOTE: positive result indicates only that the compiler
            #       did not issue a diagnostic message with the flag
            if(${cache_entry_flag_name})
                list(APPEND internal_supported_flags ${flag})
            endif()

            # unset cache to always check on cmake run
            unset(${cache_entry_flag_name} CACHE)
        endforeach()

        # invalidate cached results and update with new results
        unset(${PROJECT_NAME}_cached_c_compiler_flags CACHE)
        set(
            ${PROJECT_NAME}_cached_c_compiler_flags
                "${internal_supported_flags}"
            CACHE
                INTERNAL ""
        )

       set(${PROJECT_NAME}_force_c_compiler_flag_check OFF
            CACHE
                BOOL "Invalidate cache and check compiler flags again. Set to OFF after call."
            FORCE
        )
    endif()

    # return cached result of compiler flags check
    set(${supported_compiler_flags}
        ${${PROJECT_NAME}_cached_c_compiler_flags}
        PARENT_SCOPE
    )
endfunction()
