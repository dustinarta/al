#pragma once
#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <iomanip>
#include <limits>
#include <thread>
#include <cstdarg>
#include <cstdio>
#include <chrono>

using std::vector;
using std::string;
using std::cout;
using std::cerr;

class Matrix {
private:
public:
    uint64_t row_size;
    uint64_t col_size;
    vector<vector<double>> data;

    Matrix();
    ~Matrix();
    Matrix(Matrix*);
    Matrix(Matrix&);
    //Only set the row size and col size, not allocating space for data. Use init() to allocate data.
    Matrix(int64_t, int64_t);
    //Allocate the data by row_size and col_size
    Matrix& init(int64_t row_size, int64_t col_size);
    static Matrix from_jsonstring(string json_data);
    string to_jsonstring();
    string to_jsondictstring();
    void clear();
    //for initialization purpose
    Matrix duplicate();
    //for initialization purpose but pointer
    Matrix* duplicate_ptr();
    void move(Matrix&);
    void move(Matrix*);
    //Copy
    Matrix transpose();
    //Copy
    Matrix fast_transpose(const int thread_count = 2);
    //Copy
    Matrix inverse();
    //Copy
    Matrix fast_inverse(const int thread_count = 2);
    Matrix operator=(Matrix);
    Matrix operator=(Matrix&);
    Matrix operator=(Matrix&&);
    Matrix operator+(Matrix);
    Matrix operator-(Matrix);
    Matrix operator*(Matrix);
    Matrix operator+(double);
    Matrix operator-(double);
    Matrix operator*(double);
    Matrix operator/(double);
    
    Matrix add(Matrix);
    Matrix min(Matrix);
    Matrix mul(Matrix);
    Matrix add(double);
    Matrix min(double);
    Matrix mul(double);
    Matrix div(double);

    
    //Self
    Matrix fast_self_add(Matrix matrix, const int thread_count = 2);
    //Self
    Matrix fast_self_min(Matrix matrix, const int thread_count = 2);

    //Copy
    Matrix fast_add(Matrix matrix, const int thread_count = 2);
    //Copy
    Matrix fast_min(Matrix matrix, const int thread_count = 2);
    //Copy
    Matrix fast_mul(Matrix matrix, const int thread_count = 2);

    //Copy
    std::vector<Matrix> split_row(int count);
    //Copy
    std::vector<Matrix> split_col(int count);
    //Copy
    static Matrix join_row(std::vector<Matrix>& matrices);
    //Copy (optimized)
    static Matrix join_col(std::vector<Matrix>& matrices);
    static std::vector<Matrix> multi_mul(std::vector<Matrix>& left, std::vector<Matrix>& right);
    static std::vector<Matrix> multi_fast_mul(std::vector<Matrix>& left, std::vector<Matrix>& right, const int thread_count);
    static void multi_self_add(std::vector<Matrix>& left, std::vector<Matrix>& right);
    static void multi_self_min(std::vector<Matrix>& left, std::vector<Matrix>& right);
    static void multi_self_mul(std::vector<Matrix>& matrices, double number);
    static void multi_self_div(std::vector<Matrix>& matrices, double number);

    Matrix& self_add(Matrix);
    Matrix& self_min(Matrix);
    Matrix& self_mul(double);
    Matrix& self_div(double);

    //Self
    Matrix& fill_force(vector<vector<double>>);
    //Self
    Matrix& fill_random(double low, double high);
    //Self
    Matrix& fill_diagonal(double diagonal, double rest);
    //Self
    Matrix& resquare_diagonal(double diagonal);
    //Self
    Matrix& resize_square(uint64_t size);
    //Self
    void pop_row(int count);
    //
    bool is_equal_shape(Matrix);
    bool is_square();
};

extern std::ostream& operator<<(std::ostream& os, Matrix mat);
extern std::ostream& operator<<(std::ostream& os, std::vector<double> vector);
