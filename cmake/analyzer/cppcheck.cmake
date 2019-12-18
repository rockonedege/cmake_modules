# Provides function to register target to cppcheck.
#
# The following cache variables will be set/provided:
#     <project-name>_use_cppcheck - True if cppcheck was found.
#
# The following function will be provided:
#     register_for_cppcheck - add pre build cppcheck step to target

include_guard(GLOBAL)

# search for 'cppcheck' executable
find_program(cppcheck_executable NAMES "cppcheck")

# define cache variable which can be used to toggle the usage
set(${PROJECT_NAME}_use_cppcheck OFF
    CACHE
        BOOL "cppcheck will be used"
    FORCE
)

if(NOT cppcheck_executable)
    message(WARNING "cppcheck was not found!")
    message(WARNING "Calling 'register_for_cppcheck' will not have an effect.")
else()
    set(${PROJECT_NAME}_use_cppcheck ON
        CACHE
            BOOL "cppcheck will be used"
        FORCE
    )
    message(STATUS "Found cppcheck: ${cppcheck_executable}")
endif()

#[[

Helper function to create pre build step to run cppcheck for the given target.

register_for_cppcheck(<target>)

NOTE: The target needs to have the 'SOURCES' and 'INCLUDE_DIRECTORIES' properties set.

#]]
function(register_for_cppcheck target)
    if(${PROJECT_NAME}_use_cppcheck)
        get_target_property(sources ${target} SOURCES)
        get_target_property(include_dirs ${target} INCLUDE_DIRECTORIES)

        # don't check against .ui files from Qt
        list(FILTER sources EXCLUDE REGEX ".*(ui)")

        # iterate over the 'include_dirs' and add '-I' in front of each directory
        set(include_dirs_as_parameter)
        foreach(include_dir ${include_dirs})
            list(APPEND include_dirs_as_parameter "-I${include_dir}")
        endforeach()

        # if the project is build with Qt, the auto generated include directory should be added
        if(${${PROJECT_NAME}_with_qt})
            list(APPEND include_dirs_as_parameter
                "-I${CMAKE_CURRENT_BINARY_DIR}/${target}_autogen/include"
            )
        endif()

        add_custom_command(
            TARGET
                ${target}
            PRE_BUILD
                COMMENT "[----] Running cppcheck on target: ${target}"
            COMMAND
                ${cppcheck_executable}
                --language=c++
                --std=c++17
                --platform=native
                --enable=warning,performance,portability,style,information
                --template=gcc
                --suppress=syntaxError
                --suppress=passedByValue
                --suppress=missingInclude
                --suppress=unusedStructMember
                --suppress=unmatchedSuppression
                --suppress=missingIncludeSystem
                --suppress=ConfigurationNotChecked
                -i "${CMAKE_CURRENT_BINARY_DIR}/${target}_autogen"
                --quiet
                ${include_dirs_as_parameter}
                ${sources}
        )
    endif()
endfunction()
