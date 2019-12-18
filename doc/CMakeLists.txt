# search for doxygen
find_package(Doxygen)

# check if not found
if(NOT DOXYGEN_FOUND)
    message(WARNING "Doxygen not found! Documentation will not be generated.")
else()
    # define input and output files
    set(doxygen_in ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
    set(doxygen_out ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)

    # configure DOXYGEN_IN file
    configure_file(${doxygen_in} ${doxygen_out} @ONLY)

    # custom target to build documentation
    add_custom_target(documentation
        ALL
        COMMAND
            Doxygen::doxygen
            ${doxygen_out}
        WORKING_DIRECTORY
            ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT
            "Generating API documentation with Doxygen"
        VERBATIM
    )

    # configure install for documentation
    install(
        DIRECTORY
            ${CMAKE_CURRENT_BINARY_DIR}/html
        DESTINATION
            share/doc/${CMAKE_PROJECT_NAME}
    )
endif()
