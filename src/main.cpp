#include "meta_information.hxx"

#include <cstdlib>
#include <iostream>

auto main([[maybe_unused]] int argc, [[maybe_unused]] char** argv) -> int {
    // print out meta information
    std::cout << "> Name: " << meta_info::g_project_name << '\n';
    std::cout << "> Description: " << meta_info::g_project_description << '\n';

    std::cout << "> Version: " << meta_info::g_version << '\n';
    std::cout << "> Revision: " << meta_info::g_version_revision << '\n';

    std::cout << "> Build type: " << meta_info::g_build_type << '\n';
    std::cout << "> Compiler: " << meta_info::g_compiler << '\n';

    // preferred over return 0
    return EXIT_SUCCESS;
}
