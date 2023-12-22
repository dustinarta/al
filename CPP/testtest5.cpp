#include "matrix.hpp"


int main(int argc, char const *argv[])
{
    int split_count = 6;
    Matrix mat1 = Matrix().init(5, 18).fill_random(-5, 5);
    Matrix mat2 = Matrix().init(3, 4).fill_random(-5, 5);

    // std::vector<Matrix> mats1 = mat1.split_row(4);
    std::vector<Matrix> mats1 = mat1.split_col(split_count);
    for (size_t i = 0; i < split_count; i++)
    {
        cout << mats1[i];
    }
    // cout << "good";
    // return 0;
    std::vector<Matrix> mats2(split_count);
    for (size_t i = 0; i < split_count; i++)
    {
        mats2[i].move(mat2.duplicate_ptr());
    }
    
    std::vector<Matrix> mats3 = Matrix::multi_mul(mats1, mats2);
    for (size_t i = 0; i < split_count; i++)
    {
        cout << mats3[i];
    }
    cout << Matrix::join_col(mats3);
    cout << "okay";
    return 0;
}
