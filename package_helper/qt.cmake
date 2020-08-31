# The following functions will be provided:
#   - link_qt5_to_target

include_guard(GLOBAL)

# find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)

# run moc automatically when needed
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# search for qt libraries
# NOTE: Uncomment specific modules if required by target
find_package(Qt5
    COMPONENTS
        Core
        # Gui
        # Widgets
        # Network
        # Multimedia
        # MultimediaWidgets
    REQUIRED
)

# disable qt5 custom compile features
set_property(TARGET Qt5::Core
    PROPERTY
        INTERFACE_COMPILE_FEATURES ""
)

#[[

Helper function to link Qt5 to the given target.

link_qt5_to_target(<target>)

NOTE: Uncomment specific modules if required by target

#]]
function(link_qt5_to_target target)
    # define internal cache variable
    set(${PROJECT_NAME}_with_qt "ON" CACHE INTERNAL "Qt5 will be used")

    target_link_libraries(${target} Qt5::Core)
    # target_link_libraries(${target} Qt5::Gui)
    # target_link_libraries(${target} Qt5::Widgets)
    # target_link_libraries(${target} Qt5::Network)
    # target_link_libraries(${target} Qt5::Multimedia)
    # target_link_libraries(${target} Qt5::MultimediaWidgets)
endfunction()
