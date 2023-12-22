#include <iostream>
#include <map>
#include <unordered_map>


int main(int argc, char const *argv[])
{
    std::map<std::string, uint64_t> map;
    map["su"] = 10;
    // map.
    std::cout << map["su"];
    return 0;
}
