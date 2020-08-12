# Provides function to check if a faster linker is available.
#
# The following function will be provided:
#     check_available_linker - Checks which linker is available on the system

include_guard(GLOBAL)

#[[

Check if a faster linker is available on the system.

check_available_linker(<var>)

- <var>
Stores the resulting linker flags in the given variable.
The content of the given variable will be completely overridden.

NOTE:
For the 'lld' and 'gold' linker additional flags are added to the result.
    * -Wl,--no-undefined
        Report unresolved symbols even if the linker is creating a shared library.
    * -Wl,--no-allow-shlib-undefined
        Do not allow unresolved references in shared libraries.

#]]
function(check_available_linker returned_linker_flags)
    if(UNIX)
        set(common_linker_flags "-Wl,--no-undefined;-Wl,--no-allow-shlib-undefined")
        # variables which hold linker specific flags
        set(lld_linker_flags "-fuse-ld=lld;${common_linker_flags}")
        set(gnu_gold_linker_flags "-fuse-ld=gold;${common_linker_flags}")

        # use cached value to avoid multiple 'execute_process()' calls if the function
        # is used in multiple projects which depend on each other (e.g. add_subdirectory)
        if(available_linker)
            if("${available_linker}" MATCHES "LLD")
                set(${returned_linker_flags} "${lld_linker_flags}" PARENT_SCOPE)
                return()
            elseif("${available_linker}" MATCHES "GNU gold")
                set(${returned_linker_flags} "${gnu_gold_linker_flags}" PARENT_SCOPE)
                return()
            endif()
        endif()

        # check which compiler is available
        if(CMAKE_CXX_COMPILER)
            set(compiler ${CMAKE_CXX_COMPILER})
        elseif(CMAKE_C_COMPILER)
            set(compiler ${CMAKE_C_COMPILER})
        else()
            message(FATAL_ERROR "Required compiler for neither C or C++ was found!")
        endif()

        # only check for 'LLD' for Clang compiler as GCC does not seem to be supported
        if(("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang") OR
            ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang"))
            # first test for 'LLD' which should be the fastest linker
            execute_process(
                COMMAND
                    ${compiler}
                    -fuse-ld=lld -Wl,--version
                ERROR_QUIET
                OUTPUT_VARIABLE
                    linker_version
            )
        else()
            set(linker_version "")
        endif()

        if("${linker_version}" MATCHES "LLD")
            message(STATUS "Found linker: LLD")
            set(available_linker "LLD" CACHE INTERNAL "")
            set(${returned_linker_flags} "${lld_linker_flags}" PARENT_SCOPE)
        else()
            execute_process(
                COMMAND
                    ${compiler}
                    -fuse-ld=gold -Wl,--version
                ERROR_QUIET
                OUTPUT_VARIABLE
                    linker_version
            )

            if("${linker_version}" MATCHES "GNU gold")
                message(STATUS "Found linker: GNU gold")
                set(available_linker "GNU gold" CACHE INTERNAL "")
                set(${returned_linker_flags} "${gnu_gold_linker_flags}" PARENT_SCOPE)
            endif()
        endif()
    else()
        set(${returned_linker_flags} "" PARENT_SCOPE)
    endif()
endfunction()
