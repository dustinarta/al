#include "dictionary.hpp"

bool has_keys(std::vector<std::string> keys, std::string key);

Dictionary::Dictionary(){

}

void Dictionary::set(std::string key, std::any value){
    if (!has_keys(keys, key))
    {
        keys.push_back(key);
    }
    map[key] = value;
}

std::any Dictionary::get(std::string key){
    return map[key];
}

bool has_keys(std::vector<std::string> keys, std::string key){
    for (size_t i = 0; i < keys.size(); i++)
    {
        if(keys[i] == key){
            return true;
        }
    }
    return false;
}


std::ostream& operator<<(std::ostream& os, Dictionary dictionary){
    
}