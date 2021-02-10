# The following functions will be provided:
#   - get_common_cxx_compiler_flags
#   - get_common_c_compiler_flags

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
            -pedantic # warnings demanded by strict ISO C and ISO C++
            -pedantic-errors # turn pedantic warnings into errors
            -Wextra # collection of multiple flags
            -Wall # collection of multiple flags
            -Wdouble-promotion # implicit conversion increases floating-point precision
            -Wundef # X is not defined, evaluates to 0
            -Wshadow # declaration shadows something
            -Wnull-dereference # binding dereferenced null pointer to reference has UB
            -Wzero-as-null-pointer-constant # zero as null pointer constant
            -Wunused # warn on anything being unused
            -Wold-style-cast # use of old-style cast
            -Wsign-compare # comparison of integers of different signs
            -Wunreachable-code # code will never be executed
            -Wunreachable-code-break # 'break' will never be executed
            -Wunreachable-code-return # 'return' will never be executed
            -Wextra-semi-stmt # empty expression statement has no effect
            -Wreorder # warn on anything that will be initialized after use
            -Wcast-qual # cast drops qualifiers
            -Wconversion # implicit conversion
            -Wfour-char-constants # multi-character character constant
            -Wformat=2 # warn on security issues around functions that format output
            -Wheader-hygiene # using namespace directive in global context in header
            -Wnewline-eof # no newline at end of file
            -Wnon-virtual-dtor # X has virtual functions but non-virtual destructor
            -Wpointer-arith # warn of problems with pointer arithmetic
            -Wfloat-equal # comparing floating point with == or != is unsafe
            -Wpragmas # warn on wrong #pragma usage
            -Wreserved-user-defined-literal # invalid suffix on literal
            -Wsuper-class-method-mismatch # method parameter type does not match super class
            -Wswitch-enum # warn when enumeration values are not handles in switch
            -Wcovered-switch-default # default label in switch which covers all enumeration values
            -Wthread-safety # warn on anything that breaks thread safety
            -Wunused-exception-parameter # unused exception parameter
            -Wvector-conversion # incompatible vector types
            -Wkeyword-macro # keyword is hidden by macro definition
            -Wformat-pedantic # format type mismatch
            -Woverlength-strings # string literal exceeds maximum length
            -Wdocumentation # warn on documentation mismatches and related problems
            -Wimplicit-fallthrough # unannotated fall-through between switch labels
            -Wchar-subscripts # array subscript is of type 'char'
            -Wmisleading-indentation # statement is not part of the previous if/else/for/while
            -Wmissing-braces # suggest braces around initialization of subobject
            -Wpessimizing-move # moving a temporary object prevents copy elision
            -Wdeprecated-copy # implicit copy is deprecated because it has a user-declared copy
            -Wredundant-move # redundant move in return statement
            -Wtype-limits # comparison is always true or always false due to the limited range
            -fno-common # compile common globals like normal definitions
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
            # thinks the flag could be used but on the real build all flags are used
            # and 'GCC' would throw an error.
            list(APPEND compiler_flags
                -Wno-gnu-zero-variadic-macro-arguments # must specify at least one argument
            )
        endif()

        if(${PROJECT_NAME}_compiler_warnings_as_errors)
            list(APPEND compiler_flags
                -Werror # turn all warnings into errors
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
            -pedantic # warnings demanded by strict ISO C and ISO C++
            -pedantic-errors # turn pedantic warnings into errors
            -Wextra # collection of multiple flags
            -Wall # collection of multiple flags
            -Wdouble-promotion # implicit conversion increases floating-point precision
            -Wundef # X is not defined, evaluates to 0
            -Wshadow # declaration shadows something
            -Wnull-dereference # binding dereferenced null pointer to reference has UB
            -Wunused # warn on anything being unused
            -Wsign-compare # comparison of integers of different signs
            -Wunreachable-code # code will never be executed
            -Wunreachable-code-break # 'break' will never be executed
            -Wunreachable-code-return # 'return' will never be executed
            -Wextra-semi-stmt # empty expression statement has no effect
            -Wreorder # warn on anything that will be initialized after use
            -Wcast-qual # cast drops qualifiers
            -Wconversion # implicit conversion
            -Wfour-char-constants # multi-character character constant
            -Wformat=2 # warn on security issues around functions that format output
            -Wheader-hygiene # using namespace directive in global context in header
            -Wnewline-eof # no newline at end of file
            -Wpointer-arith # warn of problems with pointer arithmetic
            -Wfloat-equal # comparing floating point with == or != is unsafe
            -Wpragmas # warn on wrong #pragma usage
            -Wswitch-enum # warn when enumeration values are not handles in switch
            -Wcovered-switch-default # default label in switch which covers all enumeration values
            -Wthread-safety # warn on anything that breaks thread safety
            -Wkeyword-macro # keyword is hidden by macro definition
            -Wformat-pedantic # format type mismatch
            -Wdocumentation # warn on documentation mismatches and related problems
            -Wimplicit-fallthrough # unannotated fall-through between switch labels
            -Wmisleading-indentation # statement is not part of the previous if/else/for/while
            -Wmissing-braces # suggest braces around initialization of subobject
            -fno-common # compile common globals like normal definitions
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
                -Wno-gnu-zero-variadic-macro-arguments # must specify at least one argument
            )
        endif()

        if(${PROJECT_NAME}_compiler_warnings_as_errors)
            list(APPEND compiler_flags
                -Werror # turn all warnings into errors
            )
        endif()
    else()
        message(WARNING "Compiler (${CMAKE_C_COMPILER_ID}) not supported!")
    endif()

    # safe result in the given output variable
    set(${output_var} ${compiler_flags} PARENT_SCOPE)
endfunction()
