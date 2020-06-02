# Provides functions to get the common compiler flags.
#
# The following functions will be provided:
#     get_common_cxx_compiler_flags - provide common C++ compiler flags
#     get_common_c_compiler_flags - provide common C compiler flags

include_guard(GLOBAL)

#[[

Provide common C++ compiler flags which follow the 'C++ Tool Guide'.

get_common_cxx_compiler_flags(<output-var>)

- <output-var>
Stores the resulting common compiler flags for the current used compiler.
The content of the given variable will be completely overridden.

The following cache variables will be set/provided:
    <project-name>_compiler_warnings_as_errors - True if compiler warnings should be treated as
                                                 errors.
#]]
function(get_common_cxx_compiler_flags output_var)
    # define cache variable
    set(${PROJECT_NAME}_compiler_warnings_as_errors OFF
        CACHE
            BOOL "Treat compiler warnings as errors"
    )

    if(("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU") OR ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang"))
        # list of compiler flags which should be used
        list(APPEND compiler_flags
            -pedantic
            -pedantic-errors
            -Wextra
            -Wall
            -Wdouble-promotion
            -Wundef
            -Wshadow
            -Wnull-dereference
            -Wzero-as-null-pointer-constant
            -Wunused
            -Wold-style-cast
            -Wsign-compare
            -Wunreachable-code
            -Wunreachable-code-break
            -Wunreachable-code-return
            -Wextra-semi-stmt
            -Wreorder
            -Wcast-qual
            -Wconversion
            -Wfour-char-constants
            -Wformat=2
            -Wheader-hygiene
            -Wnewline-eof
            -Wnon-virtual-dtor
            -Wpointer-arith
            -Wfloat-equal
            -Wpragmas
            -Wreserved-user-defined-literal
            -Wsuper-class-method-mismatch
            -Wswitch-enum
            -Wcovered-switch-default
            -Wthread-safety
            -Wunused-exception-parameter
            -Wvector-conversion
            -Wkeyword-macro
            -Wformat-pedantic
            -Woverlength-strings
            -Wdocumentation
        )

        if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            # needed because of a bad behavior of 'GCC' from the manual:
            # -------------------------------------------------------------
            # When an unrecognized warning option is requested (-Wunknown-warning),
            # GCC emits a diagnostic stating that the option is not recognized. However, if the
            # -Wno- form is used, the behavior is slightly different: no diagnostic is produced
            # for -Wno-unknown-warning unless other diagnostics are being produced.
            # -------------------------------------------------------------
            # As CMake's `check_cxx_compiler_flag` checks each flag in isolation 'GCC'
            # things the flag could be used but on the real build all flags are used
            # and 'GCC' would throw an error.
            list(APPEND compiler_flags
                -Wno-gnu-zero-variadic-macro-arguments
            )
        endif()

        if(${PROJECT_NAME}_compiler_warnings_as_errors)
            list(APPEND compiler_flags
                -Werror
            )
        endif()
    else()
        message(WARNING "Compiler (${CMAKE_CXX_COMPILER_ID}) not supported!")
    endif()

    # safe result in the given output variable
    set(${output_var} ${compiler_flags} PARENT_SCOPE)
endfunction()

#[[

Provide common C compiler flags.

get_common_c_compiler_flags(<output-var>)

- <output-var>
Stores the resulting common compiler flags for the current used compiler.
The content of the given variable will be completely overridden.

The following cache variables will be set/provided:
    <project-name>_compiler_warnings_as_errors - True if compiler warnings should be treated as
                                                 errors.
#]]
function(get_common_c_compiler_flags output_var)
    # define cache variable
    set(${PROJECT_NAME}_compiler_warnings_as_errors OFF
        CACHE
            BOOL "Treat compiler warnings as errors"
    )

    if(("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU") OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang"))
        # list of compiler flags which should be used
        list(APPEND compiler_flags
            -pedantic
            -pedantic-errors
            -Wextra
            -Wall
            -Wdouble-promotion
            -Wundef
            -Wshadow
            -Wnull-dereference
            -Wunused
            -Wsign-compare
            -Wunreachable-code
            -Wunreachable-code-break
            -Wunreachable-code-return
            -Wextra-semi-stmt
            -Wreorder
            -Wcast-qual
            -Wconversion
            -Wfour-char-constants
            -Wformat=2
            -Wheader-hygiene
            -Wnewline-eof
            -Wpointer-arith
            -Wfloat-equal
            -Wpragmas
            -Wswitch-enum
            -Wcovered-switch-default
            -Wthread-safety
            -Wkeyword-macro
            -Wformat-pedantic
            -Wdocumentation
        )

        if("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang")
            # needed because of a bad behavior of 'GCC' from the manual:
            # -------------------------------------------------------------
            # When an unrecognized warning option is requested (-Wunknown-warning),
            # GCC emits a diagnostic stating that the option is not recognized. However, if the
            # -Wno- form is used, the behavior is slightly different: no diagnostic is produced
            # for -Wno-unknown-warning unless other diagnostics are being produced.
            # -------------------------------------------------------------
            # As CMake's `check_cxx_compiler_flag` checks each flag in isolation 'GCC'
            # things the flag could be used but on the real build all flags are used
            # and 'GCC' would throw an error.
            list(APPEND compiler_flags
                -Wno-gnu-zero-variadic-macro-arguments
            )
        endif()

        if(${PROJECT_NAME}_compiler_warnings_as_errors)
            list(APPEND compiler_flags
                -Werror
            )
        endif()
    else()
        message(WARNING "Compiler (${CMAKE_C_COMPILER_ID}) not supported!")
    endif()

    # safe result in the given output variable
    set(${output_var} ${compiler_flags} PARENT_SCOPE)
endfunction()
