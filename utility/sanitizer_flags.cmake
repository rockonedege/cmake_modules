# Provides function to get sanitizer related flags.
#
# The following function will be provided:
#     get_sanitizer_flags - provides flags for the requested sanitizer

include_guard(GLOBAL)

#[[

Helper function to provide flags for the requested sanitizer.

get_sanitizer_flags(RESULT <var>
                    [ADDRESS]
                    [LEAK]
                    [UNDEFINED_BEHAVIOR]
                    [MEMORY]
                    [THREAD]
)

- RESULT
Stores the resulting flags as list.
The content of the given variable will be completely overridden.

- ADDRESS
Option to request flags for the Address sanitizer.
NOTE: Also returns the flag '-fno-omit-frame-pointer'.

- LEAK
Option to request flags for the Leak sanitizer.

- UNDEFINED_BEHAVIOR
Option to request flags for the Undefined Behavior sanitizer.

- MEMORY
Option to request flags for the Memory sanitizer.
NOTE: Also returns the flag '-fno-omit-frame-pointer'.

- THREAD
Option to request flags for the Thread sanitizer.

#]]
function(get_sanitizer_flags)
    # define arguments for cmake_parse_arguments
    list(APPEND options
        ADDRESS
        LEAK
        UNDEFINED_BEHAVIOR
        MEMORY
        THREAD
    )
    list(APPEND one_value_args
        RESULT
    )

    # use cmake helper function to parse passed arguments
    cmake_parse_arguments(
        tpre
        "${options}"
        "${one_value_args}"
        ""
        ${ARGN}
    )

    # check for required arguments
    if(NOT DEFINED tpre_RESULT)
        message(FATAL_ERROR "RESULT argument required!")
    endif()

    if(tpre_ADDRESS)
        list(APPEND requested_sanitizer "address")
    endif()

    if(tpre_LEAK)
        list(APPEND requested_sanitizer "leak")
    endif()

    if(tpre_UNDEFINED_BEHAVIOR)
        list(APPEND requested_sanitizer "undefined")
    endif()

    if(tpre_MEMORY)
        if(tpre_ADDRESS OR tpre_LEAK OR tpre_THREAD)
            message(WARNING "Memory sanitizer incompatible with Address, Thread and Leak.")
        else()
            list(APPEND requested_sanitizer "memory")
        endif()
    endif()

    if(tpre_THREAD)
        if(tpre_ADDRESS OR tpre_LEAK)
            message(WARNING "Thread sanitizer incompatible with Address and Leak.")
        else()
            list(APPEND requested_sanitizer "thread")
        endif()
    endif()

    if(NOT "${requested_sanitizer}" STREQUAL "")
        list(JOIN requested_sanitizer "," sanitizer_as_comma_list)
        list(APPEND result "-fsanitize=${sanitizer_as_comma_list}")
    endif()

    if("address" IN_LIST requested_sanitizer OR "memory" IN_LIST requested_sanitizer)
        # to get nicer/meaningful stack traces in error messages
        list(APPEND result "-fno-omit-frame-pointer")
    endif()

    set(${tpre_RESULT} ${result} PARENT_SCOPE)
endfunction()
