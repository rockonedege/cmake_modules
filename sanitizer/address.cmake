# Provides function to get address sanitizer related flags.
#
# The following function will be provided:
#     get_address_sanitizer_flags() - provide address sanitizer related flags

include_guard(GLOBAL)

#[[

Provide address sanitizer related flags.

get_address_sanitizer_flags(<output-var>)

- <output-var>
Stores the resulting flags as list in the given variable.
The content of the given variable will be completely overridden.

TODO:
- add option to toggle sanitizer usage
- check if compiler supports sanitizer usage
- check if other sanitizer are used which conflict with this sanitizer

#]]
function(get_address_sanitizer_flags output_var)
    set(${output_var} "-fsanitize=address;-fno-omit-frame-pointer" PARENT_SCOPE)
endfunction()
