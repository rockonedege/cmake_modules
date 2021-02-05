# cmake_modules

This repository provides a wide range of CMake helper files.

## Table of Contents

* [Description](#description)
* [Requirements](#requirements)
* [Usage](#usage)
* [License](#license)

## Description

They were initially produced during the course of developing a C++ template
project which should lower the entry level to start a new project with CMake as
build system.

The CMake files were written with modern CMake in mind. Each file is properly
documented with a starting section listing the provided functions and file-wide
cache variables and each function also documents its arguments.

## Requirements

- [CMake][] >= 3.17.0

## Usage

Get a copy of the repository and place it inside or near your project. The
preferred way of using `cmake_modules` is as Git submodule.

```sh
$ git submodule add https://github.com/sblumentritt/cmake_modules.git <path>
```

To access the CMake files without the full path it is advised to append
`cmake_modules` to the `CMAKE_MODULE_PATH` variable.

```cmake
list(APPEND CMAKE_MODULE_PATH "<path to cmake_modules>")
```

Afterwards the CMake files can be easily included via `include(<folder>/<file
basename>)`.

```cmake
include(utility/build_type_handler) # -> ../cmake_modules/utility/build_type_handler.cmake
include(compiler/compiler_flag_check) # -> ../cmake_modules/compiler/compiler_flag_check.cmake
include(analyzer/clang_tidy) # -> ../cmake_modules/analyzer/clang_tidy.cmake
```

## License

The project is licensed under the MIT license. See [LICENSE](LICENSE) for more
information.

[CMake]: https://cmake.org/
