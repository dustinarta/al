#include <iostream>
#include <fstream>
#include <json-c/json.h>

using namespace std;

int main(int argc, char const *argv[])
{
    std::ifstream file;
    file.open("file.json", std::ios::in);
    file.seekg(0, std::ios::end);
    uint64_t fsize = file.tellg();
    file.seekg(0, std::ios::beg);

    char buffer[fsize];
    file.read(buffer, fsize);
    json_object* json = json_tokener_parse(buffer);
    json_object* json_rowsize;
   
    json_object_object_get_ex(json, "rowsize", &json_rowsize);
    cout << json_object_get_int(json_rowsize) << endl;
    cout << "succes";
    return 0;
}

