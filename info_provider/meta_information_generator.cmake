# Provides function to generate a project meta information header file.
#
# The following function will be provided:
#     generate_meta_information_header - generate a C++ header with meta informations

include_guard(GLOBAL)

#[[

Generate a C++ header in the build directory which contain project related meta informations.

generate_meta_information_header(<project-name> <version-revision>)

- <project-name>
Name of the project for which the meta information should be generated.

- <version-revision>
Variable which should be used for the 'version revision'. Preferable use the git revision.

#]]
function(generate_meta_information_header name_of_project version_revision)
    set(meta_project_name "${name_of_project}")
    set(meta_project_description "${${name_of_project}_DESCRIPTION}")
    set(meta_project_homepage_url "${${name_of_project}_HOMEPAGE_URL}")

    set(meta_version "${${name_of_project}_VERSION}")
    set(meta_version_revision "${version_revision}")

    set(meta_version_major "${${name_of_project}_VERSION_MAJOR}")
    set(meta_version_minor "${${name_of_project}_VERSION_MINOR}")
    set(meta_version_patch "${${name_of_project}_VERSION_PATCH}")
    set(meta_version_tweak "${${name_of_project}_VERSION_TWEAK}")

    set(meta_build_type "${CMAKE_BUILD_TYPE}")
    set(meta_compiler "${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")

    # configure template header file to get meta information in source code
    configure_file(
        ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/templates/meta_information.hxx.in
        ${CMAKE_CURRENT_BINARY_DIR}/meta_information.hxx
        @ONLY
    )
endfunction()
