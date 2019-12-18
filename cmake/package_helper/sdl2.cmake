# Provides function to link SDL2 to target.
#
# The following function will be provided:
#     link_sdl2_to_target - links SDL2 to target
#
# NOTE: On including the file the library is searched. If the library is not found a 'FATAL_ERROR'
#       message is thrown.
#
# NOTE: This is a work in progress file which does not contain additional libraries.

include_guard(GLOBAL)

# search for SDL2 library
find_package(SDL2 REQUIRED)

# check if not found
if(NOT SDL2_FOUND)
    message(FATAL_ERROR "[${PROJECT_NAME}] SDL2 not found!")
endif()

#[[

Helper function to link SDL2 to the given target.

link_sdl2_to_target(<target>)

#]]
function(link_sdl2_to_target target_name)
    target_include_directories(${target_name} PRIVATE ${SDL2_INCLUDE_DIRS})
    target_link_libraries(${target_name} ${SDL2_LIBRARIES})
endfunction()
