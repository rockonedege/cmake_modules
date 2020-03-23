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
                    STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo"
            )
        endif()

        # check if the build type is valid
        set(valid_build_types "Debug" "Release" "MinSizeRel" "RelWithDebInfo")

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
