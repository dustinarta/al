#include "coder.hpp"

Coder::Coder(){

}

void Coder::init(int vector_size){
    Matrix expected1 = Matrix().init(vector_size, vector_size).fill_random(-1.0, 1.0);
    Matrix expected2 = Matrix().init(vector_size, vector_size).fill_random(-1.0, 1.0);
    Query = Matrix().init(vector_size, vector_size).fill_random(-1.0, 1.0);
    // Key = Matrix().init(vector_size, vector_size).fill_random(-1.0, 1.0);
    Key = (Query.inverse()) * expected1;
    // Value = Matrix().init(vector_size, vector_size).fill_random(-1.0, 1.0);
    Value = (expected1.inverse()) * expected2;
}

Matrix fast_forward(Matrix input1, Matrix input2, const int thread_count){
    Matrix query = input1.fast_mul(Query, thread_count);
    Matrix key = input2.fast_mul(Key, thread_count);
    Matrix value = input2.fast_mul(Value, thread_count);
    Matrix attention = query.fast_mul(key.fast_transpose(thread_count), thread_count);
    Matrix output = attention.fast_mul(value, thread_count);
    _result[0] = input1;
    _result[1] = input2;
    _result[2] = query;
    _result[3] = key;
    _result[4] = value;
    _result[5] = attention;
    _result[6] = output;
    _result[7] = output.add(input1);
    return _result[7];
}

Matrix Coder::forward(Matrix input1, Matrix input2){
    Matrix query = input1 * Query;
    Matrix key = input2 * Key;
    Matrix value = input2 * Value;
    Matrix attention = query * (key.transpose());
    Matrix output = attention * value;
    _result[0] = input1;
    _result[1] = input2;
    _result[2] = query;
    _result[3] = key;
    _result[4] = value;
    _result[5] = attention;
    _result[6] = output;
    _result[7] = output.add(input1);
    return _result[7];
}

Matrix Coder::learn(Matrix error, double rate){
    Matrix next_error;

    

    return next_error;
}
