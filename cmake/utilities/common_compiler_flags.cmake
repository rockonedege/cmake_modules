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

    if(DEFINED ENV{TEAMCITY_VERSION})
        # on teamcity we require that the warnings should be treated as errors
        set(${PROJECT_NAME}_compiler_warnings_as_errors ON
            CACHE
                BOOL "Treat compiler warnings as errors"
            FORCE
        )
    endif()

    if((CMAKE_CXX_COMPILER_ID MATCHES GNU) OR (CMAKE_CXX_COMPILER_ID MATCHES Clang))
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
            -Wno-gnu-zero-variadic-macro-arguments
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

        if(${PROJECT_NAME}_compiler_warnings_as_errors)
            list(APPEND compiler_flags
                -Werror
            )
        endif()
    elseif(CMAKE_CXX_COMPILER_ID MATCHES MSVC)
        list(APPEND compiler_flags
            /permissive-
            /W4
            /w14640
            /w14265
            /w14826
            /w14928
        )

        if(${PROJECT_NAME}_compiler_warnings_as_errors)
            list(APPEND compiler_flags
                /Wx
            )
        endif()
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

    if(DEFINED ENV{TEAMCITY_VERSION})
        # on teamcity we require that the warnings should be treated as errors
        set(${PROJECT_NAME}_compiler_warnings_as_errors ON
            CACHE
                BOOL "Treat compiler warnings as errors"
            FORCE
        )
    endif()

    if((CMAKE_C_COMPILER_ID MATCHES GNU) OR (CMAKE_C_COMPILER_ID MATCHES Clang))
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
            -Wno-gnu-zero-variadic-macro-arguments
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

        if(${PROJECT_NAME}_compiler_warnings_as_errors)
            list(APPEND compiler_flags
                -Werror
            )
        endif()
    elseif(CMAKE_C_COMPILER_ID MATCHES MSVC)
        list(APPEND compiler_flags
            /permissive-
            /W4
            /w14826
        )

        if(${PROJECT_NAME}_compiler_warnings_as_errors)
            list(APPEND compiler_flags
                /Wx
            )
        endif()
    endif()

    # safe result in the given output variable
    set(${output_var} ${compiler_flags} PARENT_SCOPE)
endfunction()
