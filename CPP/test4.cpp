#include "../matrix.hpp"
#include <fstream>

using namespace std;

int main(int argc, char const *argv[])
{
    fstream file = fstream();
    file.open("file.json", std::ios::in);
    file.seekg(0, std::ios::end);
    uint64_t fsize = file.tellg();
    file.seekg(0, std::ios::beg);

    char buffer[fsize];
    file.read(buffer, fsize);
    Matrix matrix = Matrix::from_jsonstring(buffer);
    cout << matrix;
    return 0;
}
