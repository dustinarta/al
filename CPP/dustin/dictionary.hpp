#include <iostream>
#include <vector>
#include <string>
#include <unordered_map>
#include <any>

class Dictionary
{
private:
    std::vector<std::string> keys;
    std::unordered_map<std::string, std::any> map;
public:
    Dictionary(/* args */);

    void set(std::string key, std::any value);
    std::any get(std::string key);
    std::vector<std::string> get_keys();
};

extern std::ostream& operator<<(std::ostream& os, Dictionary dictionary);

