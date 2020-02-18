cmake_minimum_required(VERSION 3.16.0 FATAL_ERROR)

# generate a compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# define top-level project
project("cxxtp"
    VERSION
        0.0.1
    DESCRIPTION
        "Template for C++ projects with CMake as build system"
    LANGUAGES
        CXX C
)

function(main)
    # global variables
    # -------------------------------------
    set(${PROJECT_NAME}_target_sample "sample")

    # append custom cmake paths to module search
    # -------------------------------------
    list(APPEND CMAKE_MODULE_PATH
        "${CMAKE_CURRENT_LIST_DIR}/cmake"
    )

    # call function which handles the project related initialization
    # e.g. creation of targets
    initialize_project()

    # unset module path to not pollute third party projects
    unset(CMAKE_MODULE_PATH)

    # call function which handles dependencies
    # e.g. with 'add_subdirectory'
    configure_dependencies()
endfunction()

function(initialize_project)
    # stop if system is not unix/linux
    # -------------------------------------
    if(NOT UNIX)
        message(FATAL_ERROR "[${PROJECT_NAME}] Only UNIX systems are supported!")
    endif()

    # define cache variables
    # -------------------------------------
    set(${PROJECT_NAME}_enable_documentation OFF
        CACHE
            BOOL "Create and install the HTML based documentation"
    )

    set(${PROJECT_NAME}_enable_tests OFF
        CACHE
            BOOL "Enable/Add tests which can be run with 'ctest' or via 'test' target"
    )

    include(utility/build_type_handler)
    handle_default_build_type()

    # includes cmake files for meta information generation
    # -------------------------------------
    include(info_provider/git_revision_description)
    get_git_revision_description(current_git_revision)

    include(info_provider/meta_information_generator)
    generate_meta_information_header("${PROJECT_NAME}" "${current_git_revision}")

    # define compiler/linker flags
    # -------------------------------------
    # get list of common compiler flags which should be used
    include(compiler/common_compiler_flags)
    get_common_cxx_compiler_flags(compiler_flags_to_test)

    # check which flags are supported by the compiler
    include(compiler/compiler_flag_check)
    check_supported_cxx_compiler_flags("${compiler_flags_to_test}" cxx_compiler_flags)

    # check if a faster linker is available
    include(utility/available_linker_check)
    check_available_linker(linker_flags)

    list(APPEND definition_flags "")
    list(APPEND sanitizer_flags "-fsanitize=undefined,address" "-fno-omit-frame-pointer")

    # target: sample
    # -------------------------------------
    # create executable target
    add_executable(${${PROJECT_NAME}_target_sample})
    add_executable(
        ${${PROJECT_NAME}_target_sample}::${${PROJECT_NAME}_target_sample}
        ALIAS
        ${${PROJECT_NAME}_target_sample}
    )

    # 'include' subdirectory which adds sources and related options to the target
    add_subdirectory(src)

    # use helper function to configure a target
    include(utility/target_configuration)
    configure_target(
        TARGET
            ${${PROJECT_NAME}_target_sample}
        CXX_STANDARD
            17
        COMPILER_FLAGS
            "${cxx_compiler_flags}"
        SANITIZER_FLAGS
            "${sanitizer_flags}"
        LINKER_FLAGS
            "${linker_flags}"
        DEFINITION_FLAGS
            "${definition_flags}"
        PRIVATE_INCLUDE_DIRS
            ${CMAKE_CURRENT_SOURCE_DIR}/include
            ${CMAKE_CURRENT_BINARY_DIR}
        BUILD_TYPE_AS_OUTPUT_DIR
    )

    # add analyzer to target
    include(analyzer/clang_tidy)
    register_for_clang_tidy(${${PROJECT_NAME}_target_sample})

    include(analyzer/cppcheck)
    register_for_cppcheck(
        TARGET
            ${${PROJECT_NAME}_target_sample}
        CXX_STANDARD
            17
    )

    # strip binary for specific build types
    include(utility/postbuild_strip_command)
    add_postbuild_strip(${${PROJECT_NAME}_target_sample})

    # define installation config for target and use GNU standard locations
    # NOTE: PREFIX=/usr/local/ by default
    include(GNUInstallDirs)
    install(
        TARGETS
            ${${PROJECT_NAME}_target_sample}
        RUNTIME
            DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY
            DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE
            DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )

    # check if cache variable is true
    if(${PROJECT_NAME}_enable_tests)
        add_subdirectory(test)
    endif()

    # check if cache variable is true
    if(${PROJECT_NAME}_enable_documentation)
        add_subdirectory(doc)
    endif()
endfunction()

function(configure_dependencies)
    # project does not have any dependencies
endfunction()

main()
