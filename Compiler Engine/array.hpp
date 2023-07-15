#include <iostream>

class Array {
    _array_data* data;
    uint64_t size;

    void append();

};

class _array_data {
    void* data;
    uint64_t length;

    _array_data(){
        data = nullptr;
        length = 0;
    }

};