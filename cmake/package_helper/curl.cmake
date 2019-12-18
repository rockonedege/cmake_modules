# Provides function to link curl to target.
#
# The following function will be provided:
#     link_curl_to_target - links curl to target
#
# NOTE: On including the file the library is searched. If the library is not found a 'FATAL_ERROR'
#       message is thrown.

include_guard(GLOBAL)

# search for curl library
find_package(CURL
    FEATURES
        SSL
    REQUIRED
)

# check if not found
if(NOT CURL_FOUND)
    message(FATAL_ERROR "[${PROJECT_NAME}] CURL not found!")
endif()

#[[

Helper function to link curl to the given target.

link_curl_to_target(<target>)

#]]
function(link_curl_to_target target)
    target_link_libraries(${target} CURL::libcurl)
endfunction()
