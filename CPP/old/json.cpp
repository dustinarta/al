#include "json.hpp"


using namespace json;


// class JsonObject
// {
// private:
//     uint8_t type;
//     value data;
// public:
//     JsonObject();
// };

void skip_white(int& index, std::string jsonstring){
    const char* str = jsonstring.c_str();
    for (size_t i = index; i < jsonstring.size(); i++)
    {
        switch (str[i])
        {
        case ' ':
        case '\t':
        case '\n':
            index = i;
            continue;
        }
        return;
    }
}

std::string retrieve_key(int& index, std::string string){
    const char* str = string.c_str();
    if (str[index] == '\"')
    {
        int len = 1;
        index ++;
        for (size_t i = index; i < string.size(); i++)
        {
            if (str[index] == '\\')
            {
                
                if (str[index] == '\"')
                {
                    len = i;
                    break;
                }
            }
            
        }
        
    }
    
}

JsonObject json::parse(std::string jsondata){

}