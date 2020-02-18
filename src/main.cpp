#include "meta_information.hxx"

#include <cstdlib>
#include <iostream>

auto main([[maybe_unused]] int argc, [[maybe_unused]] char** argv) -> int {
    // print out meta information
    std::cout << "> Name: " << meta_info::project_name << '\n';
    std::cout << "> Description: " << meta_info::project_description << '\n';

    std::cout << "> Version: " << meta_info::version << '\n';
    std::cout << "> Revision: " << meta_info::version_revision << '\n';

    std::cout << "> Build type: " << meta_info::build_type << '\n';
    std::cout << "> Compiler: " << meta_info::compiler << '\n';

    // preferred over return 0
    return EXIT_SUCCESS;
}
