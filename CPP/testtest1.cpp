#include "matrix.hpp"

int main(int argc, char const *argv[])
{
    int vector = 512;
    int sequence = 4;
    Matrix input1 = Matrix().init(sequence, vector).fill_random(-1.0, 1.0);
    Matrix input2 = Matrix().init(sequence, vector).fill_random(-1.0, 1.0);
    Matrix Query = Matrix().init(vector, vector).fill_random(-1.0, 1.0);
    Matrix Key 
    //= Matrix().init(vector, vector).fill_random(-1.0, 1.0)
    ;
    Matrix Value 
    //= Matrix().init(vector, vector).fill_random(-1.0, 1.0)
    ;

    // Matrix expected = Matrix().init(sequence, sequence).fill_random(0.0, 1.0);
    Matrix expected1 = Matrix().init(sequence, vector).fill_random(-1.0, 1.0);
    Matrix expected2 = Matrix().init(sequence, sequence).fill_random(0.0, 1.0);
    Matrix expected3 = Matrix().init(sequence, vector).fill_random(-1.5, 1.5);

    Matrix input1_d = input1.duplicate().resize_square(vector);
    Matrix input2_d = input2.duplicate().resize_square(vector);

    Matrix expected1_d = expected1.duplicate().resize_square(vector);
    Matrix expected2_d = expected2.duplicate().resize_square(vector);
    Matrix expected3_d = expected3.duplicate().resize_square(vector);
    // cout << input1.resquare_diagonal(1.0);

    // Matrix temp1 = input1.resquare_diagonal(1.0).inverse() * Query;

    Query = input1_d.inverse() * expected1_d;
    // cout << Query << "\n";
    // cout << input1.duplicate().resquare_diagonal(1.0).inverse();
    // cout << expected1.duplicate().resquare_diagonal(1.0);
    // cout << std::setprecision(15) << input1.duplicate().resquare_diagonal(1.0).inverse() - expected1.duplicate().resquare_diagonal(1.0);
    // cout << std::setprecision(15) << input1.duplicate().resquare_diagonal(1.0).inverse() * expected1.duplicate().resquare_diagonal(1.0);
    
    // cout << (input1 * Query) - expected1;
    // cout << (input1 * Query);

    Key = (input1 * Query).resquare_diagonal(1.0).inverse() * expected2_d * input2_d.inverse().transpose();
    Key = Key.transpose();
    // Key = 
    // cout << Key;
    // return 0;
    Matrix Attention = input1 * Query * Key.transpose() * input2.transpose();

    Value = input2_d.inverse() * Attention.duplicate().resize_square(vector).inverse() * (expected3-input1).resize_square(vector);
    Matrix output = (Attention * input2 * Value) + input1;
    // cout << output;
    // cout << output - expected3;
    // cout << Attention << "\n";
    // cout << Attention - expected2 << "\n";
    // cout << Query << "\n";
    // cout << Key << "\n";
    // Matrix query = input1 * Query;
    // Matrix key = input2 * Key;
    // Matrix value = input2 * Value;
    cout << "done";
    return 0;
}
