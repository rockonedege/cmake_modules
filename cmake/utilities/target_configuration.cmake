# Provides function to configure a target.
#
# The following function will be provided:
#     configure_target - configures the target with the given arguments

include_guard(GLOBAL)

#[[

Helper function to configure a target.

configure_target(TARGET <target>
                 [C_STANDARD <version>]
                 [CXX_STANDARD <version>]
                 [COMPILER_FLAGS <flag>...]
                 [SANITIZER_FLAGS <flag>...]
                 [LINKER_FLAGS <flag>...]
                 [DEFINITION_FLAGS <flag>...]
                 [PUBLIC_INCLUDE_DIRS <dir>...]
                 [PRIVATE_INCLUDE_DIRS <dir>...]
                 [BUILD_TYPE_AS_OUTPUT_DIR]
)

- TARGET
Target which should be configured.

- C_STANDARD
C standard which should be used. Will be added to the PUBLIC scope.

- CXX_STANDARD
C++ standard which should be used. Will be added to the PUBLIC scope.

- COMPILER_FLAGS
List of compiler flags. Will be added to the PRIVATE scope.

- SANITIZER_FLAGS
List of sanitizer flags. Will be added to the PRIVATE scope.
NOTE: Sanitizer flags are only added to 'Debug' and 'RelWithDebInfo' build types.

- LINKER_FLAGS
List of linker flags. Will be added to the PRIVATE scope.

- DEFINITION_FLAGS
List of definition flags. Will be added to the PRIVATE scope.

- PUBLIC_INCLUDE_DIRS
List of include directories. Will be added to the PUBLIC scope.

- PRIVATE_INCLUDE_DIRS
List of include directories. Will be added to the PRIVATE scope.

- BUILD_TYPE_AS_OUTPUT_DIR
Option which changes the build output directory and uses a sub folder with the build type.

Example:
Without the option on a 'Debug' build -> ${CMAKE_CURRENT_BINARY_DIR}/target_binary
Without the option on a 'Release' build -> ${CMAKE_CURRENT_BINARY_DIR}/target_binary

With the option on a 'Debug' build -> ${CMAKE_CURRENT_BINARY_DIR}/debug/target_binary
With the option on a 'Release' build -> ${CMAKE_CURRENT_BINARY_DIR}/release/target_binary

#]]
function(configure_target)
    # define arguments for cmake_parse_arguments
    list(APPEND options
        BUILD_TYPE_AS_OUTPUT_DIR
    )
    list(APPEND one_value_args
        TARGET
        C_STANDARD
        CXX_STANDARD
    )
    list(APPEND multi_value_args
        COMPILER_FLAGS
        SANITIZER_FLAGS
        LINKER_FLAGS
        DEFINITION_FLAGS
        PUBLIC_INCLUDE_DIRS
        PRIVATE_INCLUDE_DIRS
    )

    # use cmake helper function to parse passed arguments
    cmake_parse_arguments(
        tpre
        "${options}"
        "${one_value_args}"
        "${multi_value_args}"
        ${ARGN}
    )

    # check for required arguments
    if(NOT DEFINED tpre_TARGET)
        message(FATAL_ERROR "TARGET argument required!")
    endif()

    # set compile flags
    target_compile_options(${tpre_TARGET}
        PRIVATE
            ${tpre_COMPILER_FLAGS}
    )

    # set include directories
    target_include_directories(${tpre_TARGET}
        PUBLIC
            ${tpre_PUBLIC_INCLUDE_DIRS}
        PRIVATE
            ${tpre_PRIVATE_INCLUDE_DIRS}
    )

    # set compile definitions
    target_compile_definitions(${tpre_TARGET}
        PRIVATE
            ${tpre_DEFINITION_FLAGS}
    )

    # this enables check for extraneous files when linking
    set_target_properties(${tpre_TARGET}
        PROPERTIES
            LINK_WHAT_YOU_USE ON
    )

    # check if compiler supports an interprocedural optimization
    include(CheckIPOSupported)
    check_ipo_supported(RESULT ipo_supported OUTPUT ipo_detailed_error)
    if(ipo_supported)
        set_target_properties(${tpre_TARGET}
            PROPERTIES
                INTERPROCEDURAL_OPTIMIZATION ON
        )
    else()
        message(WARNING "IPO is not supported: ${ipo_detailed_error}")
    endif()

    # set linker options for the target
    target_link_options(${tpre_TARGET}
        PRIVATE
            ${tpre_LINKER_FLAGS}
            $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:${tpre_SANITIZER_FLAGS}>
    )

    if(DEFINED tpre_C_STANDARD)
        # set C standard for the target
        target_compile_features(${tpre_TARGET}
            PUBLIC
                c_std_${tpre_C_STANDARD}
        )

        # disable C compiler extensions e.g. GNU
        set_target_properties(${tpre_TARGET}
            PROPERTIES
                C_EXTENSIONS OFF
        )
    endif()

    if(DEFINED tpre_CXX_STANDARD)
        # set C++ standard for the target
        target_compile_features(${tpre_TARGET}
            PUBLIC
                cxx_std_${tpre_CXX_STANDARD}
        )

        # disable C++ compiler extensions e.g. GNU
        set_target_properties(${tpre_TARGET}
            PROPERTIES
                CXX_EXTENSIONS OFF
        )
    endif()

    if(tpre_BUILD_TYPE_AS_OUTPUT_DIR)
        # use output dir depending on build type
        string(TOLOWER "${CMAKE_BUILD_TYPE}" build_type_lower)
        set_target_properties(${tpre_TARGET}
            PROPERTIES
                RUNTIME_OUTPUT_DIRECTORY
                    "${build_type_lower}/"
                ARCHIVE_OUTPUT_DIRECTORY
                    "${build_type_lower}/"
                LIBRARY_OUTPUT_DIRECTORY
                    "${build_type_lower}/"
        )
    endif()
endfunction()
