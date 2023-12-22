#include <iostream>
#include <vector>
#include "matrix.hpp"


using namespace std::chrono::_V2;

// std::ostream& operator<<(std::ostream &os, void* ptr){
//     return cout << std::hex << (uint64_t)ptr;
// }

int main(int argc, char const *argv[])
{
    // cout << malloc(10);
    Matrix mat = Matrix().init(10, 10).fill_random(-1.0, 1.0);
    // Matrix mat1 = Matrix().init(400, 600).fill_random(-1.0, 1.0);
    // Matrix mat2 = Matrix().init(600, 800).fill_random(-1.0, 1.0);
    // cout << mat.inverse();
    // return 0;
    // cout << (mat1 * mat2) - (mat1.fast_mul(mat2));
    // return 0;
    // cout << mat.inverse() - mat.fast_inverse(4);
    // return 0;
    system_clock::time_point start;
    
    start = std::chrono::high_resolution_clock::now();
    // cout << 
    // mat1 * mat2;
    Matrix mat1 = mat.inverse();
    cout << double((std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::high_resolution_clock::now() - start)).count())/1000000.0 << "\n";

    // cout << mat1;
    // cout << mat2;
    // return 0;

    start = std::chrono::high_resolution_clock::now();
    // cout << 
    // mat1.fast_mul(mat2, 4);
    Matrix mat2 = mat.fast_inverse(4);
    cout << double((std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::high_resolution_clock::now() - start)).count())/1000000.0 << "\n";

    // cout << mat1 - mat2;

    return 0;
}
