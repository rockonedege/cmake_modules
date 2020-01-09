cmake_minimum_required(VERSION 3.16.0 FATAL_ERROR)

message(DEBUG "[${PROJECT_NAME}] CMake version: ${CMAKE_VERSION}")

# stop if system is not unix/linux
# -------------------------------------
if(NOT UNIX)
    message(FATAL_ERROR "[${PROJECT_NAME}] Only UNIX systems are supported!")
endif()

# define top-level project
project("cxxtp"
    VERSION
        0.0.1
    DESCRIPTION
        "Template for C++ projects with CMake as build system"
    LANGUAGES
        CXX C
)

# generate a compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

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

# append custom cmake paths to module search
# -------------------------------------
list(APPEND CMAKE_MODULE_PATH
    "${CMAKE_CURRENT_LIST_DIR}/cmake"
)

# include utility cmake files
# -------------------------------------
include(utilities/build_type_handler)
include(utilities/target_configuration)
include(utilities/postbuild_strip_command)

include(utilities/compiler_flag_check)
include(utilities/available_linker_check)

# include analyzer cmake files
# -------------------------------------
include(analyzer/clang_tidy)
include(analyzer/cppcheck)

# includes cmake files for meta information generation
# -------------------------------------
include(utilities/git_revision_description)
get_git_revision_description(current_git_revision)

include(utilities/project_meta_information)
generate_meta_information_header("${PROJECT_NAME}" "${current_git_revision}")

# include package helper cmake files
# -------------------------------------
# include(package_helper/qt)
# include(package_helper/xcb)
# include(package_helper/x11)
# include(package_helper/curl)
# include(package_helper/sdl2)
# include(package_helper/threads)
# include(package_helper/ncurses)
# include(package_helper/freetype)
# include(package_helper/fontconfig)

# define compiler/linker flags
# -------------------------------------
# list of compiler flags which should be used
list(APPEND compiler_flags_to_test
    -pedantic
    -pedantic-errors
    -Werror
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

# check which flags are supported by the compiler
check_supported_cxx_compiler_flags("${compiler_flags_to_test}" cxx_compiler_flags)

# check if a faster linker is available
check_available_linker(linker_flags)

list(APPEND definition_flags "")
list(APPEND sanitizer_flags "-fsanitize=undefined,address" "-fno-omit-frame-pointer")

# target: sample
# -------------------------------------
set(target_sample "sample")

# create executable target
add_executable(${target_sample})
add_executable(${target_sample}::${target_sample} ALIAS ${target_sample})

# 'include' subdirectory which adds sources and related options to the target
add_subdirectory(src)

# use helper function to configure a target
configure_target(
    TARGET
        ${target_sample}
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
register_for_clang_tidy(${target_sample})
register_for_cppcheck(
    TARGET
        ${target_sample}
    CXX_STANDARD
        17
)

# strip binary for specific build types
add_postbuild_strip(${target_sample})

# define installation config for target and use GNU standard locations
# NOTE: PREFIX=/usr/local/ by default
include(GNUInstallDirs)
install(
    TARGETS
        ${target_sample}
    RUNTIME
        DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

# check cache variable and if the current source dir is the project source dir
# -------------------------------------
if(${PROJECT_NAME}_enable_tests AND (PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR))
    add_subdirectory(test)
endif()

# check cache variable and if the current source dir is the project source dir
# -------------------------------------
if(${PROJECT_NAME}_enable_documentation AND (PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR))
    add_subdirectory(doc)
endif()
