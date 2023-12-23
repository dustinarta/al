#include "matrix.hpp"

using namespace std::chrono::_V2;

int main(int argc, char const *argv[])
{
    int split_count = 10;
    Matrix mat1 = Matrix().init(400, 1000).fill_random(-5, 5);
    Matrix mat2 = Matrix().init(100, 500).fill_random(-5, 5);

    // std::vector<Matrix> mats1 = mat1.split_row(4);
    std::vector<Matrix> mats1 = mat1.split_col(split_count);
    // for (size_t i = 0; i < split_count; i++)
    // {
    //     cout << mats1[i];
    // }
    cout << "good\n";
    // return 0;
    std::vector<Matrix> mats2(split_count);
    for (size_t i = 0; i < split_count; i++)
    {
        mats2[i].move(mat2.duplicate_ptr());
    }
    system_clock::time_point start;
    
    start = std::chrono::high_resolution_clock::now();
    // std::vector<Matrix> mats3 = Matrix::multi_mul(mats1, mats2);
    std::vector<Matrix> mats3 = Matrix::multi_fast_mul(mats1, mats2, 8);
    cout << "time ellapsed: " << double((std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::high_resolution_clock::now() - start)).count())/1000000.0 << "\n";

    // for (size_t i = 0; i < split_count; i++)
    // {
    //     cout << mats3[i];
    // }
    // cout << 
    Matrix::join_col(mats3);
    cout << "done";
    return 0;
}
