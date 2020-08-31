# The following functions will be provided:
#   - copy_sources_without_main
#   - copy_include_dirs

include_guard(GLOBAL)

#[[

Copy source files in `SOURCES`/`INTERFACE_SOURCES` from one target to another without
the `main.cpp` file.

copy_sources_without_main(<to-target> <from-target>)

- <to-target>
The target to which the source files should be copied.

- <from-target>
The target from which the source files should be copied.

#]]
function(copy_sources_without_main to_target from_target)
    get_target_property(sources ${from_target} SOURCES)
    get_target_property(interface_sources ${from_target} INTERFACE_SOURCES)

    # handle `PRIVATE` / `PUBLIC` sources
    foreach(file IN LISTS sources)
        # skip 'main.cpp'
        if(file MATCHES ".*main\.cpp")
            continue()
        endif()

        # check if the interface sources list does not contain the file which means
        # the file should be in the `PRIVATE` scope otherwise it should be in the
        # `PUBLIC` scope
        list(FIND interface_sources "${file}" index)
        if(index EQUAL -1) # file not found in list
            target_sources(${to_target} PRIVATE ${file})
        else()
            target_sources(${to_target} PUBLIC ${file})
        endif()
    endforeach()

    # handle `INTERFACE` sources
    foreach(file IN LISTS interface_sources)
        # skip 'main.cpp'
        if(file MATCHES ".*main\.cpp")
            continue()
        endif()

        # check if the sources list does not contain the file which means
        # file should be in the `INTERFACE` scope
        list(FIND sources "${file}" index)
        if(index EQUAL -1) # file not found in list
            target_sources(${to_target} INTERFACE ${file})
        endif()
    endforeach()
endfunction()

#[[

Copy include directories in `INCLUDE_DIRECTORIES`/`INTERFACE_INCLUDE_DIRECTORIES` from one
target to another.

copy_include_dirs(<to-target> <from-target>)

- <to-target>
The target to which the include directories should be copied.

- <from-target>
The target from which the include directories should be copied.

#]]
function(copy_include_dirs to_target from_target)
    get_target_property(include_dirs ${from_target} INCLUDE_DIRECTORIES)
    get_target_property(interface_include_dirs ${from_target} INTERFACE_INCLUDE_DIRECTORIES)

    # handle `PRIVATE` / `PUBLIC` include dirs
    foreach(dir IN LISTS include_dirs)
        # check if the interface include dir list does not contain the dir which means
        # the dir should be in the `PRIVATE` scope otherwise it should be in the
        # `PUBLIC` scope
        list(FIND interface_include_dirs "${file}" index)
        if(index EQUAL -1) # directory not found in list
            target_include_directories(${to_target} PRIVATE ${dir})
        else()
            target_include_directories(${to_target} PUBLIC ${dir})
        endif()
    endforeach()

    # handle `INTERFACE` include dirs
    foreach(dir IN LISTS interface_include_dirs)
        # check if the include dir list does not contain the dir which means
        # dir should be in the `INTERFACE` scope
        list(FIND include_dirs "${dir}" index)
        if(index EQUAL -1) # directory not found in list
            target_include_directories(${to_target} INTERFACE ${dir})
        endif()
    endforeach()
endfunction()
