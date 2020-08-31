# The following functions will be provided:
#   - link_ncurses_to_target
#
# NOTE: On including the file the library is searched. If the library is not found a 'FATAL_ERROR'
#       message is thrown.

include_guard(GLOBAL)

# use ncurses instead of curses
set(CURSES_NEED_NCURSES TRUE)

# search for curses library
find_package(Curses REQUIRED)

# check if not found
if(NOT CURSES_FOUND)
    message(FATAL_ERROR "ncurses not found!")
endif()

# define additional libraries for ncurses
list(APPEND ADDITIONAL_LIBRARIES
    panel
    form
    menu
)

#[[

Helper function to link ncurses to the given target.

link_ncurses_to_target(<target>)

#]]
function(link_ncurses_to_target target)
    target_include_directories(${target} PRIVATE ${CURSES_INCLUDE_DIRS})
    target_link_libraries(${target} ${CURSES_LIBRARIES} ${ADDITIONAL_LIBRARIES})
endfunction()
