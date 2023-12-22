#include "coder.hpp"

int main(int argc, char const *argv[])
{
    int vector_size = 16;
    Coder coder = Coder();
    coder.init(vector_size);
    Matrix input1 = Matrix().init(4, vector_size).fill_random(-1.0, 1.0);
    Matrix input2 = Matrix().init(4, vector_size).fill_random(-1.0, 1.0);
    Matrix result = coder.forward(input1, input2);
    cout << result;
    return 0;
}
