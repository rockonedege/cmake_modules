# The following functions will be provided:
#   - enforce_out_of_source_build

include_guard(GLOBAL)

#[[

Helper function to prevent in-source builds.

enforce_out_of_source_build()

#]]
function(enforce_out_of_source_build)
    # to check that the source dir != binary dir
    get_filename_component(source_path "${PROJECT_SOURCE_DIR}" REALPATH)
    get_filename_component(binary_path "${PROJECT_BINARY_DIR}" REALPATH)

    # to check that binary dir does not contain a CMakeLists.txt file
    file(TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/CMakeLists.txt" cmakelists_path)

    if(("${source_path}" STREQUAL "${binary_path}") OR (EXISTS cmakelists_path))
        set(line_one "In-source builds are disabled and discouraged.")
        set(line_two "Any directory with a CMakeLists.txt file is also not valid.")
        set(line_three "Please make a 'build' subdirectory.")
        set(line_four_first_part "Remove 'CMakeCache.txt' and 'CMakeFiles' from")
        set(line_four_second_part "'${source_path}' to prevent a broken behavior.")

        string(CONCAT whole_message
            "${line_one}\n"
            "${line_two}\n"
            "${line_three}\n"
            "${line_four_first_part} "
            "${line_four_second_part}"
        )

        message(FATAL_ERROR "${whole_message}")
    endif()
endfunction()
