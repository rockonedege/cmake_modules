# The following functions will be provided:
#   - check_atomics_compiler_support

include_guard(GLOBAL)

#[[

Check if the compiler has built-in support for 'atomics' and 'atomics64'.
If the result is false the target needs to link against something like 'libatomic'.

check_atomics_compiler_support(TARGET <target>
                               RESULT <variable>
                               [CXX_STANDARD_FLAG <flag>]
)

Example where the function would return false:
- Debian 9 x86_32 with the default Clang compiler 3.8.1

Note: The contents of CMAKE_CXX_FLAGS and its associated configuration-specific
      variables are automatically added.

- TARGET
Target from which compiler flags, definitions and linker options should be used.

- RESULT
Stores the resulting value. True if the compiler provides atomics support, False otherwise.

- CXX_STANDARD_FLAG
C++ standard version flag which should be added to the compiler flags. This is needed as
the C++ standard is normally not provided via the TARGET flags. The flag should contain the
whole command line argument, for example '-std=c++17'.

Default: "" (C++ version is the default of the current compiler.)

#]]
function(check_atomics_compiler_support)
    # define arguments for cmake_parse_arguments
    list(APPEND one_value_args
        TARGET
        RESULT
        CXX_STANDARD_FLAG
    )

    # use cmake helper function to parse passed arguments
    cmake_parse_arguments(
        tpre
        ""
        "${one_value_args}"
        ""
        ${ARGN}
    )

    # check for required arguments
    if(NOT DEFINED tpre_TARGET)
        message(FATAL_ERROR "TARGET argument required!")
    endif()

    if(NOT DEFINED tpre_RESULT)
        message(FATAL_ERROR "RESULT argument required!")
    endif()

    # cache current variables to restore them after the check
    set(old_cmake_required_flags ${CMAKE_REQUIRED_FLAGS})
    set(old_cmake_required_definitions ${CMAKE_REQUIRED_DEFINITONS})
    set(old_cmake_required_linker_options ${CMAKE_REQUIRED_LINKER_OPTIONS})

    if(DEFINED tpre_CXX_STANDARD_FLAG)
        list(APPEND CMAKE_REQUIRED_FLAG "${tpre_CXX_STANDARD_FLAG}")
    endif()

    get_target_property(compiler_flags ${tpre_TARGET} COMPILE_OPTIONS)
    if(compiler_flags)
        list(APPEND CMAKE_REQUIRED_FLAG ${compiler_flags})
    endif()

    get_target_property(definitions ${tpre_TARGET} COMPILE_DEFINITIONS)
    if(definitions)
        list(APPEND CMAKE_REQUIRED_DEFINITONS ${definitions})
    endif()

    get_target_property(linker_options ${tpre_TARGET} LINK_OPTIONS)
    if(linker_options)
        list(APPEND CMAKE_REQUIRED_LINKER_OPTIONS ${linker_options})
    endif()

    include(CheckCXXSourceCompiles)

    check_cxx_source_compiles("
#include <atomic>
std::atomic<int> x;
std::atomic<short> y;
std::atomic<char> z;
int main() {
    ++z;
    ++y;
    return ++x;
}
" cxx_atomics_compiler_provided)

    check_cxx_source_compiles("
#include <atomic>
#include <cstdint>
std::atomic<uint64_t> x (0);
int main() {
    uint64_t i = x.load(std::memory_order_relaxed);
    (void)i;
    return 0;
}
" cxx_atomics64_compiler_provided)

    # restore previous variable content
    set(CMAKE_REQUIRED_FLAGS ${old_cmake_required_flags})
    set(CMAKE_REQUIRED_DEFINITONS ${old_cmake_required_definitions})
    set(CMAKE_REQUIRED_LINKER_OPTIONS ${old_cmake_required_linker_options})

    if(cxx_atomics_compiler_provided AND cxx_atomics64_compiler_provided)
        set(${tpre_RESULT} TRUE PARENT_SCOPE)
    else()
        set(${tpre_RESULT} FALSE PARENT_SCOPE)
    endif()

    # unset cache to always check on cmake run
    unset(cxx_atomics_compiler_provided CACHE)
    unset(cxx_atomics64_compiler_provided CACHE)
endfunction()
