#include "matrix.hpp"

Matrix::Matrix(){

};

Matrix::Matrix(int64_t _row_size, int64_t _col_size){
    row_size = _row_size;
    col_size = _col_size;
};

Matrix Matrix::init(int64_t _row_size, int64_t _col_size){
    row_size = _row_size;
    col_size = _col_size;
    data.resize(row_size);
    for (size_t r = 0; r < row_size; r++)
    {
        data[r] = vector<double>(col_size);
    }
    return *this;
};

vector<double> duplicate_vector(vector<double> data){
    vector<double> new_vector = vector<double>(data.size());

    for (size_t i = 0; i < data.size(); i++)
    {
        new_vector[i] = data[i];
    }
    return new_vector;
};

Matrix Matrix::duplicate(){
    Matrix new_matrix = Matrix(row_size, col_size);
    new_matrix.data.resize(row_size);
    for (size_t r = 0; r < row_size; r++)
    {
        new_matrix.data[r] = duplicate_vector(data[r]);
    }
    return new_matrix;
};

Matrix Matrix::transpose(){
    Matrix transpose = Matrix();
    transpose.init(col_size, row_size);
    vector<vector<double>> &transpose_data = transpose.data;
    for (size_t c = 0; c < row_size; c++)
    {
        vector<double> &row = data[c];
        for (size_t r = 0; r < col_size; r++)
        {
            transpose_data[r][c] = row[r];
        }
    }
    return transpose;
}

//Slower
// Matrix Matrix::transpose(){
//     Matrix transpose = Matrix();
//     transpose.init(col_size, row_size);
//     vector<vector<double>> &transpose_data = transpose.data;
//     for (size_t r = 0; r < col_size; r++)
//     {
//         vector<double> &transpose_row = transpose_data[r];
//         for (size_t c = 0; c < row_size; c++)
//         {
//             transpose_row[c] = data[c][r];
//         }
//     }
//     return transpose;
// }

Matrix Matrix::operator+(Matrix mat){
    if (!this->is_equal_shape(mat))
    {
        cerr << "Inavlid matrix shape for +";
        exit(-1);
    }
    Matrix result = this->duplicate();
    vector<vector<double>> &result_data = result.data;
    for (size_t r = 0; r < row_size; r++)
    {
        vector<double> &result_row = result_data[r];
        vector<double> your_row = mat.data[r];
        for (size_t c = 0; c < col_size; c++)
        {
            result_row[c] += your_row[c];
        }
    }
    return result;
};

Matrix Matrix::operator-(Matrix mat){
    if (!this->is_equal_shape(mat))
    {
        cerr << "Inavlid matrix shape for -";
        exit(-1);
    }
    Matrix result = this->duplicate();
    vector<vector<double>> &result_data = result.data;
    for (size_t r = 0; r < row_size; r++)
    {
        vector<double> &result_row = result_data[r];
        vector<double> your_row = mat.data[r];
        for (size_t c = 0; c < col_size; c++)
        {
            result_row[c] -= your_row[c];
        }
    }
    return result;
};

Matrix Matrix::operator*(Matrix mat){
    if (col_size != mat.row_size)
    {
        cerr << "Inavlid matrix shape for *";
        exit(-1);
    }
    Matrix result = Matrix(row_size, mat.col_size);
    result.data.resize(row_size);
    vector<vector<double>> &result_data = result.data;
    for (size_t r = 0; r < row_size; r++)
    {
        vector<double> &my_row = data[r];
        vector<double> temp_row(mat.col_size);
        for (size_t c = 0; c < mat.col_size; c++)
        {
            double number = 0.0;
            for (size_t i = 0; i < col_size; i++)
            {
                number += my_row[i] * mat.data[i][c];
            }
            temp_row[c] = number;
        }
        result_data[r] = temp_row;
    }
    return result;
}

Matrix Matrix::operator+(double number){
    Matrix result = Matrix().init(row_size, col_size);
    
}

bool Matrix::is_equal_shape(Matrix mat){
    return((row_size == mat.row_size) && (col_size == mat.col_size));
};

Matrix Matrix::fill(vector<vector<double>> _data){
    int64_t this_row_size = _data.size();
    int64_t this_col_size = _data[0].size();

    for (size_t i = 1; i < this_row_size; i++)
    {
        if (this_col_size != _data[i].size())
        {
            cerr << "Invalid column size for fill!\n";
            exit(-1);
        }
    }
    row_size = this_row_size;
    col_size = this_col_size;
    data = _data;
    return *this;
}

Matrix Matrix::fill_random(double low, double high){
    //LO + static_cast <float> (rand()) /( static_cast <float> (RAND_MAX/(HI-LO)));

    for (size_t r = 0; r < row_size; r++)
    {
        vector<double> &row = data[r];
        for (size_t c = 0; c < col_size; c++)
        {
            row[c] = low + static_cast <float> (rand()) /( static_cast <float> (RAND_MAX/(high-low)));
        }
    }
    return *this;
}

std::ostream& operator<<(std::ostream& os, Matrix mat){
    os << "[row size: " << mat.row_size << ", col size: " << mat.col_size << ", data: {";

    vector<double> &row = mat.data[0];
    os << "{" << row[0];
    for (size_t c = 1; c < mat.col_size; c++)
    {
        os << ", " << row[c];
    }
    os << "}";

    for (size_t r = 1; r < mat.row_size; r++)
    {
        vector<double> &row = mat.data[r];
        os << ", {" << row[0];
        for (size_t c = 1; c < mat.col_size; c++)
        {
            os << ", " << row[c];
        }
        os << "}";
    }
    
    os << "}]\n";
    return os;
};

std::ostream& operator<<(std::ostream& os, vector<double> data){
    os << "{" << data[0];
    for (size_t i = 1; i < data.size(); i++)
    {
        os << ", " << data[i];
    }
    os << "}";
    
    return os;
};

// Matrix Matrix::operator=(vector<vector<double>> _data){
//     int64_t this_col_size = _data[0].size();
//     for (size_t i = 1; i < this_col_size; i++)
//     {
//         if (this_col_size != _data[i].size())
//         {
//             cerr << "Invalid size in assigment!\n";
//             return;
//         }
//     }
//     this->row_size = _data.size();
//     this->col_size = this_col_size;
//     this->data = _data;
// }


