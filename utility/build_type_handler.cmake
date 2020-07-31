# Provides function to handle build type if none is given.
#
# The following function will be provided:
#     handle_default_build_type - set default build type

include_guard(GLOBAL)

#[[

Helper function to handle the default build type if none is given.

handle_default_build_type()

If no build type is defined a default type will be set. The other build types will be made
available for the CMake GUI/TUI application.

#]]
function(handle_default_build_type)
    # only check against CMAKE_BUILD_TYPE if generation is not for an IDE
    if(NOT CMAKE_CONFIGURATION_TYPES)
        define_coverage_build_type_variables()

        # define default build type variable
        set(default_build_type "Debug")

        # check if no build type is available
        if(NOT CMAKE_BUILD_TYPE)
            message(STATUS "Setting build type to '${default_build_type}' as none was specified.")

            # set build type to default
            set(CMAKE_BUILD_TYPE "${default_build_type}"
                CACHE
                    STRING "Choose the type of build."
                FORCE
            )

            # set possible values for CMake GUI/TUI
            set_property(
                CACHE
                    CMAKE_BUILD_TYPE
                PROPERTY
                    STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo" "Coverage"
            )
        endif()

        # check if the build type is valid
        set(valid_build_types "Debug" "Release" "MinSizeRel" "RelWithDebInfo" "Coverage")

        if(NOT CMAKE_BUILD_TYPE IN_LIST valid_build_types)
            string(REPLACE ";" " / " info_build_types "${valid_build_types}")
            message(FATAL_ERROR "Invalid build type! [${info_build_types}]")
        endif()

        # print current build type
        message(VERBOSE "Build Type: ${CMAKE_BUILD_TYPE}")
    else()
        message(VERBOSE "Build type handling does not have an effect for IDE generators!")
    endif()
endfunction()

#[[

-- INTERNAL FUNCTION

Defines global CMake variables for the Coverage build type.

define_coverage_build_type_variables()

TODO:
- add option to use different flags for Clang compiler
  (https://clang.llvm.org/docs/SourceBasedCodeCoverage.html)
- handle compiler which do not support coverage e.g. MSVC
#]]
function(define_coverage_build_type_variables)
    set(compiler_flags "-g -O0 -fprofile-arcs -ftest-coverage")
    set(linker_flags "--coverage")

    set(CMAKE_C_FLAGS_COVERAGE "${compiler_flags}"
        CACHE
            STRING "Flags used by the C compiler during coverage builds."
        FORCE
    )
    set(CMAKE_CXX_FLAGS_COVERAGE "${compiler_flags}"
        CACHE
            STRING "Flags used by the C++ compiler during coverage builds."
        FORCE
    )
    set(CMAKE_EXE_LINKER_FLAGS_COVERAGE "${linker_flags}"
        CACHE
            STRING "Flags used for linking binaries during coverage builds."
        FORCE
    )
    set(CMAKE_SHARED_LINKER_FLAGS_COVERAGE "${linker_flags}"
        CACHE
            STRING "Flags used by the shared libraries linker during coverage builds."
        FORCE
    )

    mark_as_advanced(
        CMAKE_C_FLAGS_COVERAGE
        CMAKE_CXX_FLAGS_COVERAGE
        CMAKE_EXE_LINKER_FLAGS_COVERAGE
        CMAKE_SHARED_LINKER_FLAGS_COVERAGE
    )
endfunction()
