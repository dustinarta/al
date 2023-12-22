#include "matrix.hpp"


void _skip_white(const char* ptr, int& i){
    while (true){
        if (ptr[i] == ' ')
        {
            i++;
            continue;
        }else if (ptr[i] == '\t')
        {
            i++;
            continue;
        }else if (ptr[i] == '\n')
        {
            i++;
            continue;
        }else
        {
            return;
        }
    }
};

bool _is_number(char c){
    if (c >= 48 and c <= 57) return true;
    else return c == '-';
};

double _string_to_float(const char* ptr, int& i){
    bool minus = false;
	double result = 0.0;
    char c = ptr[i];
    if(c == '-') {
        minus = true;
        i++;
    } 
    while (true){
        c = ptr[i];
		if(c == '.') break;
		else if(c >= 48 && c <= 57){
			int v = c - 48;
			result *= 10;
			result += v;
		}else{
            if (minus) return -result;
            else return result;
        } 
        i++;
    }
	i++;
	double devider = 1;
    while (true){
		char c = ptr[i];
		devider /= 10;
		if(c >= 48 && c <= 57){
			int v = c - 48;
			result += v * devider;
		}else{
            if (minus) return -result;
            else return result;
        }
        i++;
    }
	if (minus) return -result;
    else return result;
};

std::vector<double> _string_to_vectorfloat(const char* ptr, int& i){
	std::vector<double> result;
    while (true)
    {
        _skip_white(ptr, i);
        char c = ptr[i];
        if (c == '['){
            i++;
            _skip_white(ptr, i);
            continue;
        }else if (c == ','){
            i++;
            _skip_white(ptr, i);
            continue;
        }else if (c == ']'){
            break;
        }else if (_is_number(c)){
            double value = _string_to_float(ptr, i);
            result.push_back(value);
            // cout << std::fixed << value << "\n";
            continue;
        }else{
            break;
        }
    }
	return result;
};

std::vector<std::vector<double>> _string_to_vectorvectorfloat(const char* ptr, int& i){
	std::vector<std::vector<double>> result;
    while (true)
    {
        _skip_white(ptr, i);
        char c = ptr[i];
        if (c == '['){
            i++;
            _skip_white(ptr, i);
            c = ptr[i];
            if (c == '['){
                std::vector<double> vector = _string_to_vectorfloat(ptr, i);
                // cout << ptr[i];
                result.push_back(vector);
                i++;
                continue;
            }else{
                break;
            }
        }else if (c == ','){
            i++;
            _skip_white(ptr, i);
            c = ptr[i];
            if (c == '['){
                std::vector<double> vector = _string_to_vectorfloat(ptr, i);
                // cout << ptr[i];
                result.push_back(vector);
                i++;
                continue;
            }else{
                break;
            }
        }else if (c == ']'){
            break;
        }else{
            break;
        }
    }
	return result;
};

std::string _string_to_string(const char* ptr, int& i){
    std::string result;
    char c = ptr[i];
    if (c != '"'){
        return result;
    }
    char* temp = new char[1];
    int tempsize = 1;
    int size = 0;
    i++;
    int offset = 0;
    while (true){
        c = ptr[i];
        if (c >= 32 and c <= 126){
            if (c == '"'){
                break;
            }else if (c == '\\')
			{
				i++;
				c = ptr[i];
				if (c == 't'){
					size++;
					if (size > tempsize){
						tempsize *= 2;
						temp = (char*)realloc(temp, tempsize);
					}
					temp[size-1] = '\t';
				}else if (c == 'n'){
					size++;
					if (size > tempsize){
						tempsize *= 2;
						temp = (char*)realloc(temp, tempsize);
					}
					temp[size-1] = '\n';
				}else if (c == '\"'){
					size++;
					if (size > tempsize){
						tempsize *= 2;
						temp = (char*)realloc(temp, tempsize);
					}
					temp[size-1] = '\"';
				}else{
					cerr << "Invalid escape character";
					exit(-1);
				}
			}
			else{
                size++;
				if (size > tempsize){
					tempsize *= 2;
					temp = (char*)realloc(temp, tempsize);
				}
                temp[size-1] = c;
            }
        }else{
            cerr << "weird char " << c;
            exit(-1);
        }
        i++;
    }
    temp[size] = '\0';
	result = temp;
	free(temp);
    return result;
};

std::ostream& operator<<(std::ostream& os, std::vector<double> vector){
    os << "[";
    for (size_t i = 0; i < vector.size()-1; i++)
    {
        os << std::fixed << vector[i] << ", ";
    }
    os << vector.back() << "]";
    return os;
}

std::ostream& operator<<(std::ostream& os, std::vector<std::vector<double>> vector){
    os << "[";
    for (size_t i = 0; i < vector.size()-1; i++)
    {
        os << std::fixed << vector[i] << ", ";
    }
    os << vector.back() << "]";
    return os;
}

int main(int argc, char const *argv[])
{
    int i = 0;
    // cout << _string_to_float("10.9087", i);
    // cout << std::vector<double>({10, 90, 89});
    // cout << _string_to_vectorfloat("[ 10.9087 , 90.999]", i);
    // cout << _string_to_vectorvectorfloat("\n[\n[\t10.9087 , 90.999] , [92 ,\t 87 , 65\n ] \n", i);
    // int i = 0;
	// cout << _string_to_string("\"\\\"90\\\"\"", i);
    const char* str = "[\n[0.999999999999999889, 0.000000000000000056, 0.000000000000000083, 0.000000000000000194, -0.000000000000000402, 0.000000000000000049, 0.000000000000000004, 0.000000000000000389, 0.000000000000000014, 0.000000000000000174], \n[-0.000000000000000621, 1.000000000000000000, 0.000000000000000111, -0.000000000000000167, -0.000000000000000944, -0.000000000000000111, -0.000000000000000002, 0.000000000000000333, 0.000000000000000333, 0.000000000000000330] \n]";
    // const char* str = "[\n[-0.000000000000000621, 1.000000000000000000, 0.000000000000000111, -0.000000000000000167, -0.000000000000000944, -0.000000000000000111, -0.000000000000000002, 0.000000000000000333, 0.000000000000000333, 0.000000000000000330], \n]";
    // const char* str = "[\n[1.000000000000000000], \n]";
    cout << _string_to_vectorvectorfloat(str, i);
    return 0;
}
