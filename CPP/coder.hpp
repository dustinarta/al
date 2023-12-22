#pragma once
#include "matrix.hpp"

class Coder {
private:
    Matrix Query;
    Matrix Key;
    Matrix Value;
    std::array<Matrix, 8> _result;

public:
    Coder();
    void init(int vector_size);

    Matrix forward(Matrix input1, Matrix input2);
    Matrix learn(Matrix error, double rate);
};