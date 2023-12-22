#pragma once
#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <iomanip>
#include <limits>
#include <unordered_map>
#include <variant>


namespace json
{
    enum datatype {
        null,
        number,
        string,
        boolean,
        array,
        dictionary,
    };
    
    // typedef std::variant<double, std::string, bool, > variant;

    union variant
    {
        double number;
        std::string string;
        bool boolean;
        void* collection;
    };
    
    class JsonObject {
        datatype type;
        variant value;
    };

    
    JsonObject parse(std::string jsondata);
    std::string stringify(JsonObject jsondata);
};
