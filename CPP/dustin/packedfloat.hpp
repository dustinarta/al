#include <iostream>



class PackedFloat
{
private:
    uint64_t size;
    uint64_t space;
    double* data;
public:
    PackedFloat(/* args */);
    void push_back(double new_data);
    void append(double new_data);
    void append(PackedFloat new_array);
    PackedFloat duplicate();
    void clear();

    void prepare(int new_space);
    int get_size();
};
