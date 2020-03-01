# Provides function to get undefined behavior sanitizer related flags.
#
# The following function will be provided:
#     get_undefined_behavior_sanitizer_flags() - provide undefined behavior sanitizer related flags

include_guard(GLOBAL)

#[[

Provide undefined behavior sanitizer related flags.

get_undefined_behavior_sanitizer_flags(<output-var>)

- <output-var>
Stores the resulting flags as list in the given variable.
The content of the given variable will be completely overridden.

TODO:
- add option to toggle sanitizer usage
- check if compiler supports sanitizer usage
- check if other sanitizer are used which conflict with this sanitizer

#]]
function(get_undefined_behavior_sanitizer_flags output_var)
    set(${output_var} "-fsanitize=undefined" PARENT_SCOPE)
endfunction()
