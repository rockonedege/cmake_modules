# The following functions will be provided:
#   - link_xcb_to_target
#
# NOTE: On including the file the library is searched. If the library is not found a 'FATAL_ERROR'
#       message is thrown.

include_guard(GLOBAL)

# list of component which should be used
# NOTE: Uncomment required components from the list below.
list(APPEND xcb_components
    xcb

    # extra components
    # xcb-shm
    # xcb-res
    # xcb-record
    # xcb-randr
    # xcb-xf86dri
    # xcb-composite
    # xcb-dpms
    # xcb-shape
    # xcb-xv
    # xcb-xfixes
    # xcb-dri2
    # xcb-glx
    # xcb-present
    # xcb-damage
    # xcb-dri3
    # xcb-xinerama
    # xcb-xtest
    # xcb-render
    # xcb-xvmc
    # xcb-screensaver
    # xcb-sync

    # special header naming
    # xcb-util
    # xcb-cursor
    # xcb-ewmh
    # xcb-icccm
    # xcb-image
    # xcb-keysyms
    # xcb-renderutil
    # xcb-xrm

    # experimental
    # xcb-xkb
    # xcb-xinput
)

# list of components with a leading "xcb_" in header names
list(APPEND xcb_special_header_handling
    xcb-util
    xcb-cursor
    xcb-ewmh
    xcb-icccm
    xcb-image
    xcb-keysyms
    xcb-renderutil
    xcb-xrm
)

# needed to handle standard variables for components
include(FindPackageHandleStandardArgs)

# iterate over each component in the list and search for header and library
foreach(component ${xcb_components})
    # create variable used for cmake package names
    string(TOUPPER ${component} current_component)
    string(REPLACE "-" "_" current_component ${current_component})

    if(component IN_LIST xcb_special_header_handling)
        # some header start with "xcb_" for whatever reason
        string(REPLACE "xcb-" "xcb_" header_name ${component})
    else()
        # remove leading "xcb-" because the headernames do not contain the string
        string(REPLACE "xcb-" "" header_name ${component})
    endif()

    # search for include path
    find_path(${current_component}_INCLUDE_DIR xcb/${header_name}.h)

    # search for library
    if(${component} STREQUAL "xcb-renderutil")
        find_library(${current_component}_LIBRARY NAMES "xcb-render-util")
    else()
        find_library(${current_component}_LIBRARY NAMES ${component})
    endif()

    # populate standard variables
    find_package_handle_standard_args(${component}
        FOUND_VAR
            ${component}_FOUND
        REQUIRED_VARS
            ${current_component}_LIBRARY
            ${current_component}_INCLUDE_DIR
    )

    mark_as_advanced(${current_component}_INCLUDE_DIR ${current_component}_LIBRARY)

    if(NOT ${component}_FOUND)
        message(WARNING "${component} not found!")
    else()
        set(current_imported_target xcb::${current_component})

        # create imported target
        add_library(${current_imported_target} UNKNOWN IMPORTED)
        set_target_properties(${current_imported_target}
                PROPERTIES
                    IMPORTED_LOCATION ${${current_component}_LIBRARY}
                    INTERFACE_INCLUDE_DIRECTORIES ${${current_component}_INCLUDE_DIR}
        )
    endif()
endforeach()

# check against XCB_FOUND which is always required
if(NOT XCB_FOUND)
    message(FATAL_ERROR "xcb not found!")
endif()

#[[

Helper function to link xcb to the given target.

link_xcb_to_target(<target>)

#]]
function(link_xcb_to_target target)
    foreach(component ${xcb_components})
        # create variable used for cmake package names
        string(TOUPPER ${component} current_component)
        string(REPLACE "-" "_" current_component ${current_component})

        target_link_libraries(${target} xcb::${current_component})
    endforeach()
endfunction()
