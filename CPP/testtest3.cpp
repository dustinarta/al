#include "matrix.hpp"
#include <chrono>

using namespace std::chrono::_V2;

uint64_t itteration = 200000000;


int size = 20;
void array_loop(double* array);
void vector_loop(std::vector<double> vector);
int main(int argc, char const *argv[])
{
    std::vector<double> vector = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
    double array[] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
    system_clock::time_point start;
    
    start = std::chrono::high_resolution_clock::now();
    array_loop(array);
    cout << "pointer array: " << double((std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::high_resolution_clock::now() - start)).count())/1000000.0 << "\n";

    start = std::chrono::high_resolution_clock::now();
    vector_loop(vector);
    cout << "vector: " << double((std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::high_resolution_clock::now() - start)).count())/1000000.0 << "\n";

    return 0;
}
void array_loop(double* array){
    for (size_t i = 0; i < itteration; i++)
    {
        array[i%size] = i;
    }
}
void vector_loop(std::vector<double> vector){
    for (size_t i = 0; i < itteration; i++)
    {
        vector[i%size] = i;
    }
}
