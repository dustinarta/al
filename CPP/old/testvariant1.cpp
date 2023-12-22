#include <iostream>
#include <variant>
#include <vector>

typedef std::variant<std::string, double, uint64_t> variant;

std::ostream& operator<<(std::ostream& ostream, std::vector<variant> array){
    ostream << "[";
    if (array.size() == 0)
    {
        return ostream << "]";
    }
    size_t i;
    for (i = 0; i < array.size()-1; i++)
    {
        switch (array[i].index())
        {
        case 0:
            ostream << std::get<std::string>(array[i]);
            break;
        case 1:
            ostream << std::get<double>(array[i]);
            break;
        case 2:
            ostream << std::get<uint64_t>(array[i]);
            break;
        default:
            break;
        }
        ostream << ", ";
    }
    switch (array[i].index())
    {
    case 0:
        ostream << std::get<std::string>(array[i]);
        break;
    case 1:
        ostream << std::get<double>(array[i]);
        break;
    case 2:
        ostream << std::get<uint64_t>(array[i]);
        break;
    default:
        break;
    }
    ostream << "]";
    return ostream;
}

int main(int argc, char const *argv[])
{
    std::vector<variant> items = {
        variant(10ul),
        variant(10.0124),
        variant(std::string("ambatukam"))
    };
    std::cout << items;
    return 0;
}

