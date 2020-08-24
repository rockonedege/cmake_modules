# Provides function to setup build type related variables.
#
# The following function will be provided:
#     setup_build_type_variables - sets build type related variables

include_guard(GLOBAL)

#[[

Helper function to setup build type related variables.

setup_build_type_variables()

If no build type is defined a default type will be set. The other build types will be made
available for the CMake GUI/TUI application.

Default build type: Debug
Valid build types: Debug, Release, MinSizeRel, RelWithDebInfo, Coverage

The following cache variables will be set/provided:
    <project-name>_force_coverage_flags_for_gcov - Set to ON to use flags to generate GCOV data
                                                   for all supported compiler.

#]]
function(setup_build_type_variables)
    define_coverage_build_type_variables()

    get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    if(is_multi_config)
        if(NOT "Coverage" IN_LIST CMAKE_CONFIGURATION_TYPES)
            list(APPEND CMAKE_CONFIGURATION_TYPES Coverage)
        endif()
    else()
        # define valid build types which should be available for single-config generators
        set(valid_build_types "Debug" "Release" "MinSizeRel" "RelWithDebInfo" "Coverage")

        # define default build type variable
        set(default_build_type "Debug")

        # set possible values for CMake GUI/TUI
        set_property(
            CACHE
                CMAKE_BUILD_TYPE
            PROPERTY
                STRINGS "${valid_build_types}"
        )

        # check if CMake was called without defining a build type
        if(NOT CMAKE_BUILD_TYPE)
            message(STATUS "Setting build type to '${default_build_type}' as none was specified.")

            # set build type to default
            set(CMAKE_BUILD_TYPE "${default_build_type}"
                CACHE
                    STRING "Choose the type of build"
                FORCE
            )
        elseif(NOT CMAKE_BUILD_TYPE IN_LIST valid_build_types)
            string(REPLACE ";" " | " info_build_types "${valid_build_types}")
            message(FATAL_ERROR "Invalid build type: '${CMAKE_BUILD_TYPE}' [${info_build_types}]")
        endif()

        # print current build type
        message(VERBOSE "Build Type: ${CMAKE_BUILD_TYPE}")
    endif()
endfunction()

#[[

-- INTERNAL FUNCTION

Defines global CMake variables for the Coverage build type.

define_coverage_build_type_variables()

The following cache variables will be set/provided:
    <project-name>_force_coverage_flags_for_gcov - Set to ON to use flags to generate GCOV data
                                                   for all supported compiler.

#]]
function(define_coverage_build_type_variables)
    # define cache variable which can be used to toggle the usage
    set(${PROJECT_NAME}_force_coverage_flags_for_gcov OFF
        CACHE
            BOOL "Force the use of flags to generate GCOV data for all supported compiler"
    )

    if(${PROJECT_NAME}_force_coverage_for_gcov
        OR ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU"))
        set(compiler_flags "-g -O0 -fprofile-arcs -ftest-coverage")
        set(linker_flags "--coverage")
    elseif(("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang"))
        # flags for https://clang.llvm.org/docs/SourceBasedCodeCoverage.html
        set(compiler_flags "-g -O0 -fprofile-instr-generate -fcoverage-mapping")
        set(linker_flags "-fprofile-instr-generate")
    else()
        message(STATUS "Coverage flags not available for the given compiler")
    endif()

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
