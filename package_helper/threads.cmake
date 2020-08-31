# The following functions will be provided:
#   - link_threads_to_target
#
# NOTE: On including the file the library is searched. If the library is not found a 'FATAL_ERROR'
#       message is thrown.

include_guard(GLOBAL)

# search for threads library
find_package(Threads REQUIRED)

# check if not found
if(NOT Threads_FOUND)
    message(FATAL_ERROR "Threads not found!")
endif()

#[[

Helper function to link Threads to the given target.

link_threads_to_target(<target>)

#]]
function(link_threads_to_target target)
    target_link_libraries(${target} Threads::Threads)
endfunction()
