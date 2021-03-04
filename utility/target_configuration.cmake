# The following functions will be provided:
#   - configure_target

include_guard(GLOBAL)

#[[

Helper function to configure a target.

configure_target(TARGET <target>
                 [C_STANDARD <version>]
                 [CXX_STANDARD <version>]
                 [COMPILER_FLAGS <flag>...]
                 [SANITIZER_FLAGS <flag>...]
                 [LINKER_FLAGS <flag>...]
                 [<scope>_DEFINITION_FLAGS <flag>...]
                 [<scope>_INCLUDE_DIRS <dir>...]
                 [BUILD_TYPE_AS_OUTPUT_DIR]
                 [ENABLE_UNUSED_SECTION_GARBAGE_COLLECTION]
)

The available values for all arguments with '<scope>' are:
    - PUBLIC
    - INTERFACE
    - PRIVATE

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

- PUBLIC_DEFINITION_FLAGS
List of definition flags. Will be added to the PUBLIC scope.

- PRIVATE_DEFINITION_FLAGS
List of definition flags. Will be added to the PRIVATE scope.

- INTERFACE_DEFINITION_FLAGS
List of definition flags. Will be added to the INTERFACE scope.

- PUBLIC_INCLUDE_DIRS
List of include directories. Will be added to the PUBLIC scope.

- PRIVATE_INCLUDE_DIRS
List of include directories. Will be added to the PRIVATE scope.

- INTERFACE_INCLUDE_DIRS
List of include directories. Will be added to the INTERFACE scope.

- BUILD_TYPE_AS_OUTPUT_DIR
Option which changes the build output directory and uses a sub folder with the build type.

NOTE: Only has an effect if the generator is not an IDE.

Example:
Without the option on a 'Debug' build -> ${CMAKE_CURRENT_BINARY_DIR}/target_binary
Without the option on a 'Release' build -> ${CMAKE_CURRENT_BINARY_DIR}/target_binary

With the option on a 'Debug' build -> ${CMAKE_CURRENT_BINARY_DIR}/debug/target_binary
With the option on a 'Release' build -> ${CMAKE_CURRENT_BINARY_DIR}/release/target_binary

- ENABLE_UNUSED_SECTION_GARBAGE_COLLECTION
Option which adds new compiler and linker flags to the target to allow the linker to
garbage collect unused sections in the binary which will lead to a smaller size.

#]]
function(configure_target)
    # define arguments for cmake_parse_arguments
    list(APPEND options
        BUILD_TYPE_AS_OUTPUT_DIR
        ENABLE_UNUSED_SECTION_GARBAGE_COLLECTION
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
        PUBLIC_DEFINITION_FLAGS
        PRIVATE_DEFINITION_FLAGS
        INTERFACE_DEFINITION_FLAGS
        PUBLIC_INCLUDE_DIRS
        PRIVATE_INCLUDE_DIRS
        INTERFACE_INCLUDE_DIRS
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

    # get the type of the target as INTERFACE libraries should be handled differently
    # -> only the INTERFACE scope properties can be set
    get_target_property(${tpre_TARGET}_type ${tpre_TARGET} TYPE)
    set(interface_target "FALSE")
    if(${tpre_TARGET}_type MATCHES "INTERFACE_LIBRARY")
        set(interface_target "TRUE")
    endif()


    # set compile flags
    if(DEFINED tpre_COMPILER_FLAGS AND (NOT ${interface_target}))
        target_compile_options(${tpre_TARGET}
            PRIVATE
                ${tpre_COMPILER_FLAGS}
        )
    endif()

    if(DEFINED tpre_SANITIZER_FLAGS AND (NOT ${interface_target}))
        target_compile_options(${tpre_TARGET}
            PRIVATE
                $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>,$<CONFIG:Coverage>>:${tpre_SANITIZER_FLAGS}>
        )
    endif()

    # set include directories
    if(DEFINED tpre_PUBLIC_INCLUDE_DIRS AND (NOT ${interface_target}))
        target_include_directories(${tpre_TARGET}
            PUBLIC
                ${tpre_PUBLIC_INCLUDE_DIRS}
        )
    endif()

    if(DEFINED tpre_PRIVATE_INCLUDE_DIRS AND (NOT ${interface_target}))
        target_include_directories(${tpre_TARGET}
            PRIVATE
                ${tpre_PRIVATE_INCLUDE_DIRS}
        )
    endif()

    if(DEFINED tpre_INTERFACE_INCLUDE_DIRS)
        target_include_directories(${tpre_TARGET}
            INTERFACE
                ${tpre_INTERFACE_INCLUDE_DIRS}
        )
    endif()

    # set compile definitions
    if(DEFINED tpre_PUBLIC_DEFINITION_FLAGS AND (NOT ${interface_target}))
        target_compile_definitions(${tpre_TARGET}
            PUBLIC
                ${tpre_PUBLIC_DEFINITION_FLAGS}
        )
    endif()

    if(DEFINED tpre_PRIVATE_DEFINITION_FLAGS AND (NOT ${interface_target}))
        target_compile_definitions(${tpre_TARGET}
            PRIVATE
                ${tpre_PRIVATE_DEFINITION_FLAGS}
        )
    endif()

    if(DEFINED tpre_INTERFACE_DEFINITION_FLAGS)
        target_compile_definitions(${tpre_TARGET}
            INTERFACE
                ${tpre_INTERFACE_DEFINITION_FLAGS}
        )
    endif()

    # this enables check for extraneous files when linking
    set_target_properties(${tpre_TARGET}
        PROPERTIES
            LINK_WHAT_YOU_USE ON
    )

    # set linker options for the target
    if(DEFINED tpre_LINKER_FLAGS AND (NOT ${interface_target}))
        target_link_options(${tpre_TARGET}
            PRIVATE
                ${tpre_LINKER_FLAGS}
        )
    endif()

    if(DEFINED tpre_SANITIZER_FLAGS AND (NOT ${interface_target}))
        target_link_options(${tpre_TARGET}
            PRIVATE
                $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>,$<CONFIG:Coverage>>:${tpre_SANITIZER_FLAGS}>
        )
    endif()

    if(DEFINED tpre_C_STANDARD)
        # set C standard for the target
        if(NOT ${interface_target})
            target_compile_features(${tpre_TARGET}
                PUBLIC
                    c_std_${tpre_C_STANDARD}
            )
        else()
            target_compile_features(${tpre_TARGET}
                INTERFACE
                    c_std_${tpre_C_STANDARD}
            )
        endif()

        # disable C compiler extensions e.g. GNU
        set_target_properties(${tpre_TARGET}
            PROPERTIES
                C_EXTENSIONS OFF
        )
    endif()

    if(DEFINED tpre_CXX_STANDARD)
        # set C++ standard for the target
        if(NOT ${interface_target})
            target_compile_features(${tpre_TARGET}
                PUBLIC
                    cxx_std_${tpre_CXX_STANDARD}
            )
        else()
            target_compile_features(${tpre_TARGET}
                INTERFACE
                    cxx_std_${tpre_CXX_STANDARD}
            )
        endif()

        # disable C++ compiler extensions e.g. GNU
        set_target_properties(${tpre_TARGET}
            PROPERTIES
                CXX_EXTENSIONS OFF
        )
    endif()

    if(tpre_ENABLE_UNUSED_SECTION_GARBAGE_COLLECTION AND (NOT ${interface_target}))
        if(("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
            OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU")
            OR ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            OR ("${CMAKE_C_COMPILER_ID}" STREQUAL "Clang"))

            target_compile_options(${tpre_TARGET}
                PRIVATE
                    -ffunction-sections # place each function in its own section
                    -fdata-sections # place each data in its own section
            )
            target_link_options(${tpre_TARGET}
                PRIVATE
                    -Wl,--gc-sections # enable garbage collection of unused sections
            )
        else()
            message(STATUS
                "ENABLE_UNUSED_SECTION_GARBAGE_COLLECTION has no effect for the current compiler"
            )
        endif()
    endif()

    # BUILD_TYPE_AS_OUTPUT_DIR only has an effect if the generator is not multi-config
    get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

    if(tpre_BUILD_TYPE_AS_OUTPUT_DIR AND (NOT is_multi_config))
        # use output dir depending on build type
        if(CMAKE_BUILD_TYPE)
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
        else()
            message(WARNING "The CMake variable 'CMAKE_BUILD_TYPE' is not defined!")
        endif()
    endif()
endfunction()
