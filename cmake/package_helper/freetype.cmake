# Provides function to link freetype to target.
#
# The following function will be provided:
#     link_freetype_to_target - links freetype to target
#
# NOTE: On including the file the library is searched. If the library is not found a 'FATAL_ERROR'
#       message is thrown.

include_guard(GLOBAL)

# search for freetype library
find_package(Freetype REQUIRED)

# check if not found
if(NOT FREETYPE_FOUND)
    message(FATAL_ERROR "Freetype not found!")
endif()

#[[

Helper function to link freetype to the given target.

link_freetype_to_target(<target>)

#]]
function(link_freetype_to_target target)
    target_link_libraries(${target} Freetype::Freetype)
endfunction()
