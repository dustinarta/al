#pragma once
#include <iostream>
#include <vector>

using std::vector;
using std::cout;
using std::cerr;

class Matrix {
public:
    uint64_t row_size;
    uint64_t col_size;
    vector<vector<double>> data;

    //Matrix operator=(vector<vector<double>> _data);
    Matrix();
    Matrix(int64_t, int64_t);
    //SELF
    Matrix init(int64_t, int64_t);
    Matrix duplicate();
    Matrix transpose();
    Matrix operator+(Matrix);
    Matrix operator-(Matrix);
    Matrix operator*(Matrix);
    Matrix operator+(double);
    Matrix operator-(double);
    Matrix operator*(double);
    Matrix operator/(double);
    //SELF
    Matrix fill(vector<vector<double>>);
    //SELF
    Matrix fill_random(double low, double high);
    bool is_equal_shape(Matrix);
};

extern std::ostream& operator<<(std::ostream& os, Matrix mat);
