# Provides function to get thread sanitizer related flags.
#
# The following function will be provided:
#     get_thread_sanitizer_flags() - provide thread sanitizer related flags

include_guard(GLOBAL)

#[[

Provide thread sanitizer related flags.

get_thread_sanitizer_flags(<output-var>)

- <output-var>
Stores the resulting flags as list in the given variable.
The content of the given variable will be completely overridden.

TODO:
- add option to toggle sanitizer usage
- check if compiler supports sanitizer usage
- check if other sanitizer are used which conflict with this sanitizer

#]]
function(get_thread_sanitizer_flags output_var)
    set(${output_var} "-fsanitize=thread" PARENT_SCOPE)
endfunction()
