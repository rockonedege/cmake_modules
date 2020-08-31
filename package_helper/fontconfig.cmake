# The following functions will be provided:
#   - link_fontconfig_to_target
#
# NOTE: On including the file the library is searched. If the library is not found a 'FATAL_ERROR'
#       message is thrown.

include_guard(GLOBAL)

# search for fontconfig library
find_package(Fontconfig REQUIRED)

# check if not found
if(NOT Fontconfig_FOUND)
    message(FATAL_ERROR "Fontconfig not found!")
endif()

#[[

Helper function to link fontconfig to the given target.

link_fontconfig_to_target(<target>)

#]]
function(link_fontconfig_to_target target)
    target_link_libraries(${target} Fontconfig::Fontconfig)
endfunction()
