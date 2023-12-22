#include "matrix.hpp"
#include <iostream>
#include <vector>

class Object{
public:
    int* number;
    Object(){
        std::cout << "Created\n";
        number = new int;
        *number = 2;
    }
    Object duplicate(){
        Object object = Object();
        *object.number = *number;
        return object;
    }
    // Object& duplicate(){
    //     Object* object = new Object();
    //     *object->number = *number;
    //     return *object;
    // }
    Object& set(int num){
        *number = num;
        return *this;
    }
    Object& operator=(Object obj){
        std::cout << "Assignment called\n";
        *number = *obj.number;
        return *this;
    }
};

std::ostream& operator<<(std::ostream& os, Object obj){

    return std::cout << *obj.number << " at " << std::hex << (uint64_t)obj.number;
}

int main(int argc, char const *argv[])
{
    // Object object1 = Object().set(20);
    // std::cout << object1 << "\n";
    // object1 = Object().set(30);
    // std::cout << object1 << "\n";
    // std::cout << object1;

    // std::vector<Object> objects(4);
    // std::cout << objects.size();
    // std::cout << object1.duplicate().set(90);

    // Object* objects = new Object[4];

}


