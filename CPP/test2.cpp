#include "matrix.hpp"
#include <chrono>
#include <filesystem>
#include <json/json.h>


int main(int argc, char const *argv[])
{
    Matrix mat1 = Matrix();
    mat1.init(10, 10);
    // mat1.fill_diagonal(1.0, 0.0);
    mat1.fill_random(-1.0, 1.0);
    
    // cout << mat1.inverse() * mat1;
    // auto start = std::chrono::high_resolution_clock::now();
    // mat1.inverse() * mat1;
    // cout << double((std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::high_resolution_clock::now() - start)).count())/1000000.0;
    // cout << ;
    auto store = (mat1.inverse() * mat1).to_jsondictstring();
    FILE* file = fopen("file.json", "wb");
    fwrite(store.c_str(), 1, store.size(), file);
    fclose(file);
}