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

#]]
function(check_available_linker returned_linker_flags)
    if(UNIX)
        execute_process(
            COMMAND
                ${CMAKE_CXX_COMPILER}
                -fuse-ld=lld -Wl,--version
            ERROR_QUIET
            OUTPUT_VARIABLE
                linker_version
        )

        if("${linker_version}" MATCHES "LLD")
            message(STATUS "Found linker: LLD")
            set(${returned_linker_flags} "-fuse-ld=lld" PARENT_SCOPE)
        else()
            execute_process(
                COMMAND
                    ${CMAKE_CXX_COMPILER}
                    -fuse-ld=gold -Wl,--version
                ERROR_QUIET
                OUTPUT_VARIABLE
                    linker_version
            )

            if("${linker_version}" MATCHES "GNU gold")
                message(STATUS "Found linker: GNU gold")
                set(${returned_linker_flags} "-fuse-ld=gold" PARENT_SCOPE)
            endif()
        endif()
    else()
        set(${returned_linker_flags} "" PARENT_SCOPE)
    endif()
endfunction()
