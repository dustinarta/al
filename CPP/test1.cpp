#include "matrix.hpp"
#include <chrono>


int main(int argc, char const *argv[])
{
    Matrix mat1 = Matrix();
    mat1.init(5, 3);
    // mat1.fill_random(-1.0, 1.0);
    mat1.fill(
        {
            {1, 2, 3, 4},
            {5, 6, 7, 8}
        }
    );
    // cout << mat1;
    // cout << mat1.transpose();
    cout << mat1 * mat1.transpose();
    // auto start = std::chrono::high_resolution_clock::now();
    // mat1.transpose();
    // cout << double((std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::high_resolution_clock::now() - start)).count())/1000000.0;
    return 0;
}
