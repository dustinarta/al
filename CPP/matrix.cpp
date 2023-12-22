#include "matrix.hpp"

static vector<double>& this_row_fill(vector<double>& target, double number);
static vector<double> this_row_duplicate(vector<double>& target);
static vector<double>& this_row_min(vector<double>& target, vector<double> source);
static vector<double>& this_row_mul(vector<double>& target, double number);
static vector<double>& this_row_div(vector<double>& target, double number);

std::ostream& operator<<(std::ostream &os, void* ptr){
    return cout << std::hex << (uint64_t)ptr;
}

double** vectorvector_to_arrayarray(std::vector<vector<double>> vector){
    double** result = (double**)malloc(sizeof(double*) * vector.size());

    // cout << "Array of array count : " << vector.size() << " x " << vector[0].size() << "\n";
    for (size_t i = 0; i < vector.size(); i++)
    {
        result[i] = vector[i].data();
    }
    return result;
}

Matrix::Matrix(){
    row_size = 0;
    col_size = 0;
};

Matrix::~Matrix(){
	// cout << "Destroyed matrix\n";
}

Matrix::Matrix(Matrix* matrix){
    row_size = matrix->row_size;
    col_size = matrix->col_size;
    data.resize(row_size);
    std::vector<std::vector<double>>& matrix_data = matrix->data;
    for (size_t i = 0; i < row_size; i++)
    {
        data[i] = this_row_duplicate(matrix_data[i]);
    }
};

Matrix::Matrix(Matrix& matrix){
    row_size = matrix.row_size;
    col_size = matrix.col_size;
    data.resize(row_size);
    std::vector<std::vector<double>>& matrix_data = matrix.data;
    for (size_t i = 0; i < row_size; i++)
    {
        data[i] = this_row_duplicate(matrix_data[i]);
    }
};

Matrix::Matrix(int64_t _row_size, int64_t _col_size){
    row_size = _row_size;
    col_size = _col_size;
};

Matrix& Matrix::init(int64_t _row_size, int64_t _col_size){
    row_size = _row_size;
    col_size = _col_size;
    this->data.resize(row_size);
    for (size_t r = 0; r < row_size; r++)
    {
        this->data[r] = vector<double>(col_size);
    }
    return *this;
};

vector<double> duplicate_vector(vector<double> data){
    vector<double> new_vector = vector<double>(data.size());

    for (size_t i = 0; i < data.size(); i++)
    {
        new_vector[i] = data[i];
    }
    return new_vector;
};

void _move(Matrix* left, Matrix* right){
    left->clear();
    left->row_size = right->row_size;
    left->col_size = right->col_size;
    left->data = right->data;
    right->row_size = 0;
    right->col_size = 0;
    right->data.clear();
}

void _move(Matrix* left, Matrix&& right){
    left->clear();
    left->row_size = right.row_size;
    left->col_size = right.col_size;
    left->data = right.data;
    right.row_size = 0;
    right.col_size = 0;
    right.data.clear();
}

void Matrix::move(Matrix* mat){
    _move(this, mat);
}

void Matrix::move(Matrix& mat){
    _move(this, std::move(mat));
}

Matrix Matrix::duplicate(){
    Matrix new_matrix = Matrix(row_size, col_size);
    new_matrix.data.resize(row_size);
    for (size_t r = 0; r < row_size; r++)
    {
        new_matrix.data[r] = duplicate_vector(data[r]);
    }
    return new_matrix;
};

Matrix* Matrix::duplicate_ptr(){
    Matrix* new_matrix = new Matrix(row_size, col_size);
    std::vector<std::vector<double>>& new_matrix_data = new_matrix->data;
    new_matrix_data.resize(row_size);
    for (size_t r = 0; r < row_size; r++)
    {
        new_matrix_data[r] = duplicate_vector(data[r]);
    }
    return new_matrix;
};

struct _for_fast{
    Matrix* left;
    Matrix* right;
    Matrix* result;
};

void _each_fast_transpose(void* _argument, int at_row, int to_row, uint64_t col_size){
    _for_fast *argument = (_for_fast*)_argument;
    vector<vector<double>> &transpose_data = argument->result->data;
    vector<vector<double>> &left = argument->left->data;
    for (size_t c = at_row; c < to_row; c++)
    {
        vector<double> &left_row = left[c];
        for (size_t r = 0; r < col_size; r++)
        {
            transpose_data[r][c] = left_row[r];
        }
    }
}

Matrix Matrix::fast_transpose(int thread_count){
    
    Matrix transpose = Matrix();
    transpose.init(col_size, row_size);
    _for_fast argument = {
        .left = this,
        .result = &transpose
    };
    std::thread threads[thread_count];
    double each_index = 1.0/double(thread_count);
    double from_index = 0.0;
    double to_index = each_index;
    for (size_t i = 0; i < thread_count; i++)
    {
        from_index = row_size * (i*each_index);
        to_index = row_size * ((i+1)*each_index);
        threads[i] = std::thread(_each_fast_transpose, (void*)(&argument), from_index, to_index, col_size);
    }
    for (size_t i = 0; i < thread_count; i++)
    {
        threads[i].join();
    }
    return transpose;
};

Matrix Matrix::transpose(){
    Matrix transpose = Matrix();
    transpose.init(col_size, row_size);
    vector<vector<double>> &transpose_data = transpose.data;
    for (size_t c = 0; c < row_size; c++)
    {
        vector<double> &row = data[c];
        for (size_t r = 0; r < col_size; r++)
        {
            transpose_data[r][c] = row[r];
        }
    }
    return transpose;
};

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
            cerr << "weird char " << c << std::endl;
            cout << "last " << temp;
            exit(-1);
        }
        i++;
    }
    // i++;
    temp[size] = '\0';
	result = temp;
	free(temp);
    // cout << result << " " << size;
    return result;
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

Matrix Matrix::from_jsonstring(string json_data){
    Matrix thismatrix = Matrix();
    const char* ptr = json_data.c_str();
    int i = 0;

    char c = ptr[i];
    if (c != '{'){
        cerr << "not an matrix json!";
        exit(-1);
    }
    int _param_count = 0;
    while (_param_count < 3)
    {
        _skip_white(ptr, i);
        c = ptr[i];
        if (c == '\"'){
            std::string key = _string_to_string(ptr, i);
            // cout << key << "\n";
            i++;
            if (key == "rowsize"){
                _skip_white(ptr, i);
                c = ptr[i];
                if (c == ':'){
                    i++;
                    _skip_white(ptr, i);
                    c = ptr[i];
                    if (_is_number(c)){
                        double value = _string_to_float(ptr, i);
                        thismatrix.row_size = value;
                        i++;
                        _param_count++;
                        continue;
                    }else{
                        cerr << "Expected number for row size!";
                        exit(-1);
                    }
                }
            }else if (key == "colsize"){
                _skip_white(ptr, i);
                c = ptr[i];
                if (c == ':'){
                    i++;
                    _skip_white(ptr, i);
                    c = ptr[i];
                    if (_is_number(c)){
                        double value = _string_to_float(ptr, i);
                        thismatrix.col_size = value;
                        i++;
                        _param_count++;
                        continue;
                    }else{
                        cerr << "Expected number for col size!";
                        exit(-1);
                    }
                }
            }else if (key == "data"){
                _skip_white(ptr, i);
                c = ptr[i];
                // cout << c << "\n";
                _skip_white(ptr, i);
                // cout << "1";
                if (c == ':'){
                    i++;
                    _skip_white(ptr, i);
                    // cout << "2";
                    c = ptr[i];
                    if (c == '['){
                        // cout << "3";
                        std::vector<std::vector<double>> value = _string_to_vectorvectorfloat(ptr, i);
                        // cout << "end";
                        thismatrix.data = value;
                        i++;
                        _param_count++;
                        continue;
                    }else{
                        cerr << "Invalid data!";
                        exit(-1);
                    }
                }else{
                    cerr << "else catched " << c;
                    exit(-1);
                }
                
            }
        }
        
        
        i++;
    }
    return thismatrix;
};

string Matrix::to_jsonstring(){
    std::stringstream result;
    result.precision(18);
    result << "{\"rowsize\": " << row_size << ", \"colsize\": " << col_size <<", \"data\": [";
    if(col_size > 0){
        for (size_t r = 0; r < row_size; r++)
        {
            result << "[" << data[r][0];
            for (size_t c = 1; c < col_size; c++)
            {
                result << ", " << std::fixed << data[r][c];
                // result << ", " << std::to_string(data[r][c]);
            }
            result << "], ";
        }
        result << "[" << data[row_size-1][0];
        for (size_t c = 1; c < col_size; c++)
        {
            result << ", " << data[row_size-1][c];
        }
        result << "]";
    }
    result << "]}";
    return string(result.str());
};

string Matrix::to_jsondictstring(){
    std::stringstream result;
    result.precision(18);
    result << "{\n\t\"rowsize\": " << row_size << ", \n\t\"colsize\": " << col_size <<", \n\t\"data\": [";
    if(col_size > 0){
        for (size_t r = 0; r < row_size-1; r++)
        {
            result << "\n\t\t[" << data[r][0];
            for (size_t c = 1; c < col_size; c++)
            {
                result << ", " << std::fixed << data[r][c];
                // result << ", " << std::to_string(data[r][c]);
            }
            result << "], ";
        }
        result << "\n\t\t[" << data[row_size-1][0];
        for (size_t c = 1; c < col_size; c++)
        {
            result << ", " << data[row_size-1][c];
        }
        result << "]";
    }
    result << "\n\t]\n}";
    return string(result.str());
};

void Matrix::clear(){
    for (size_t r = 0; r < row_size; r++)
    {
        data[r].clear();
    }
    data.clear();
    row_size = 0;
    col_size = 0;
}

//Slower
// Matrix Matrix::transpose(){
//     Matrix transpose = Matrix();
//     transpose.init(col_size, row_size);
//     vector<vector<double>> &transpose_data = transpose.data;
//     for (size_t r = 0; r < col_size; r++)
//     {
//         vector<double> &transpose_row = transpose_data[r];
//         for (size_t c = 0; c < row_size; c++)
//         {
//             transpose_row[c] = data[c][r];
//         }
//     }
//     return transpose;
// }

Matrix Matrix::inverse(){
    Matrix result = Matrix().init(row_size, col_size).fill_diagonal(1.0, 0.0);
    Matrix usedmatrix = this->duplicate();
    auto resultdata = result.data;
    auto usedmatrixdata = usedmatrix.data;
    for (size_t r = 0; r < row_size; r++)
    {
        double number = usedmatrixdata[r][r];
        this_row_div(resultdata[r], number);
        this_row_div(usedmatrixdata[r], number);
        for (size_t i = r+1; i < row_size; i++)
        {
            number = usedmatrixdata[i][r];
            auto temp = this_row_duplicate(resultdata[r]);
            this_row_min(
                resultdata[i],
                this_row_mul(
                    temp, number
                )
            );
            temp = this_row_duplicate(usedmatrixdata[r]);
            this_row_min(
                usedmatrixdata[i],
                this_row_mul(
                    temp, number
                )
            );
        }
    }

    for (size_t r = 0; r < row_size; r++)
    {
        for (size_t i = 0; i < r; i++)
        {
            double number = usedmatrixdata[i][r];
            auto temp = this_row_duplicate(resultdata[r]);
            this_row_min(
                resultdata[i],
                this_row_mul(
                    temp, number
                )
            );
            temp = this_row_duplicate(usedmatrixdata[r]);
            this_row_min(
                usedmatrixdata[i],
                this_row_mul(
                    temp, number
                )
            );
        }
    }
    
    result.data = resultdata;
    return result;
}

Matrix Matrix::fast_inverse(const int thread_count){
    Matrix result = Matrix().init(row_size, col_size).fill_diagonal(1.0, 0.0);
    Matrix usedmatrix = this->duplicate();
    uint64_t size = row_size;
    auto resultdata = result.data;
    auto usedmatrixdata = usedmatrix.data;
    for (size_t r = 0; r < row_size; r++)
    {
        double number = usedmatrixdata[r][r];
        std::vector<double> &this_resultdata = resultdata[r];
        std::vector<double> &this_usedmatrixdata = usedmatrixdata[r];
        for (size_t i = 0; i < size; i++)
        {
            this_resultdata[i] /= number;
            this_usedmatrixdata[i] /= number;
        }
        // cout << this_resultdata;
        // exit(-1);
        for (size_t i = r+1; i < row_size; i++)
        {
            number = usedmatrixdata[i][r];
            std::vector<double> &this_resultdata2 = resultdata[i];
            std::vector<double> &this_usedmatrixdata2 = usedmatrixdata[i];
            for (size_t j = 0; j < size; j++)
            {
                this_resultdata2[j] -= (this_resultdata[j] * number);
            }
            for (size_t j = 0; j < size; j++)
            {
                this_usedmatrixdata2[j] -= (this_usedmatrixdata[j] * number);
            }
        }
    }

    for (size_t r = 0; r < row_size; r++)
    {
        for (size_t i = 0; i < r; i++)
        {
            double number = usedmatrixdata[i][r];
            std::vector<double> &this_resultdata = resultdata[r];
            std::vector<double> &this_usedmatrixdata = usedmatrixdata[r];
            std::vector<double> &this_resultdata2 = resultdata[i];
            std::vector<double> &this_usedmatrixdata2 = usedmatrixdata[i];
            for (size_t j = 0; j < size; j++)
            {
                this_resultdata2[j] -= (this_resultdata[j] * number);
            }
            for (size_t j = 0; j < size; j++)
            {
                this_usedmatrixdata2[j] -= (this_usedmatrixdata[j] * number);
            }
        }
    }
    
    result.data = resultdata;
    return result;
}

Matrix Matrix::operator=(Matrix mat){
    uint64_t mat_row_size = mat.row_size;
    uint64_t mat_col_size = mat.col_size;
    data.resize(mat_row_size);
    for (size_t i = 0; i < row_size; i++)
    {
        data[i].resize(mat_col_size);
        std::vector<double> &my_row = data[i];
        std::vector<double> &your_row = mat.data[i];
        for (size_t c = 0; c < mat_col_size; c++)
        {
            my_row[c] = your_row[c];
        }
    }
    for (size_t i = row_size; i < mat_row_size; i++)
    {
        data[i] = std::vector<double>(mat_col_size);
        std::vector<double> &my_row = data[i];
        std::vector<double> &your_row = mat.data[i];
        for (size_t c = 0; c < mat_col_size; c++)
        {
            my_row[c] = your_row[c];
        }
    }
    row_size = mat_row_size;
    col_size = mat_col_size;
    return *this;
}

Matrix Matrix::operator=(Matrix& mat){
    uint64_t mat_row_size = mat.row_size;
    uint64_t mat_col_size = mat.col_size;
    data.resize(mat_row_size);
    for (size_t i = 0; i < row_size; i++)
    {
        data[i].resize(mat_col_size);
        std::vector<double> &my_row = data[i];
        std::vector<double> &your_row = mat.data[i];
        for (size_t c = 0; c < mat_col_size; c++)
        {
            my_row[c] = your_row[c];
        }
    }
    for (size_t i = row_size; i < mat_row_size; i++)
    {
        data[i] = std::vector<double>(mat_col_size);
        std::vector<double> &my_row = data[i];
        std::vector<double> &your_row = mat.data[i];
        for (size_t c = 0; c < mat_col_size; c++)
        {
            my_row[c] = your_row[c];
        }
    }
    row_size = mat_row_size;
    col_size = mat_col_size;
    return *this;
}

Matrix Matrix::operator=(Matrix&& mat){
    for (size_t i = 0; i < row_size; i++)
    {
        data[i].clear();
    }
    data.clear();
    data = mat.data;
    row_size = mat.row_size;
    col_size = mat.col_size;
    return *this;
}

Matrix Matrix::operator+(Matrix mat){
    return add(mat);
};

Matrix Matrix::operator-(Matrix mat){
    return min(mat);
};

Matrix Matrix::operator*(Matrix mat){
    return mul(mat);
}

Matrix Matrix::operator+(double number){
    Matrix result = Matrix().init(row_size, col_size);
    vector<vector<double>> &result_data = result.data;
    for (size_t r = 0; r < row_size; r++)
    {
        double *result_row = result_data[r].data();
        for (size_t c = 0; c < col_size; c++)
        {
            result_row[c] += number;
        }
    }
    return result;
}

Matrix Matrix::operator-(double number){
    Matrix result = Matrix().init(row_size, col_size);
    vector<vector<double>> &result_data = result.data;
    for (size_t r = 0; r < row_size; r++)
    {
        double *result_row = result_data[r].data();
        for (size_t c = 0; c < col_size; c++)
        {
            result_row[c] -= number;
        }
    }
    return result;
}

Matrix Matrix::operator*(double number){
    Matrix result = Matrix().init(row_size, col_size);
    vector<vector<double>> &result_data = result.data;
    for (size_t r = 0; r < row_size; r++)
    {
        double *result_row = result_data[r].data();
        for (size_t c = 0; c < col_size; c++)
        {
            result_row[c] *= number;
        }
    }
    return result;
}

Matrix Matrix::operator/(double number){
    Matrix result = Matrix().init(row_size, col_size);
    vector<vector<double>> &result_data = result.data;
    for (size_t r = 0; r < row_size; r++)
    {
        double *result_row = result_data[r].data();
        for (size_t c = 0; c < col_size; c++)
        {
            result_row[c] /= number;
        }
    }
    return result;
}

void _add(Matrix* left, Matrix* right, Matrix* result){
    // if (left->row_size != right->row_size)
    // {
    //     /* code */
    // }

    vector<vector<double>> &result_data = result->data;
    vector<vector<double>> &right_data = right->data;
    vector<vector<double>> &left_data = left->data;
    for (size_t r = 0; r < row_size; r++)
    {
        double *result_row = result_data[r].data();
        double* left_row = left_data[r].data();
        double* right_row = right_data[r].data();
        for (size_t c = 0; c < col_size; c++)
        {
            result_row[c] = left_row[c] + right_row[c];
        }
    }
    return result;
    
}

Matrix Matrix::add(Matrix mat){
    if (!this->is_equal_shape(mat))
    {
        cerr << "Inavlid matrix shape for +";
        exit(-1);
    }
    Matrix result = Matrix().init(row_size, col_size);
    _add(this, &mat, &result);
    return result;
};

Matrix Matrix::min(Matrix mat){
    if (!this->is_equal_shape(mat))
    {
        cerr << "Inavlid matrix shape for -";
        exit(-1);
    }
    Matrix result = this->duplicate();
    vector<vector<double>> &result_data = result.data;
    for (size_t r = 0; r < row_size; r++)
    {
        vector<double> &result_row = result_data[r];
        vector<double> your_row = mat.data[r];
        for (size_t c = 0; c < col_size; c++)
        {
            result_row[c] -= your_row[c];
        }
    }
    return result;
};

void _mul(Matrix* left, Matrix* right, Matrix* result){
    uint64_t left_col_size = left->col_size;
    uint64_t left_row_size = left->row_size;
    uint64_t right_col_size = right->col_size;
    uint64_t right_row_size = right->row_size;
    if (left_col_size != right_row_size)
    {
        cerr << "Inavlid matrix shape for *";
        exit(-1);
    }
    // *result = Matrix(left_row_size, right_col_size);
    // result.data.resize(left_row_size);
    vector<vector<double>> &result_data = result->data;
    vector<vector<double>> &left_data = left->data;
    vector<vector<double>> &right_data = right->data;
    for (size_t r = 0; r < left_row_size; r++)
    {
        vector<double> &left_row = left_data[r];
        vector<double> temp_row(right_col_size);
        for (size_t c = 0; c < right_col_size; c++)
        {
            double number = 0.0;
            for (size_t i = 0; i < left_col_size; i++)
            {
                number += left_row[i] * right_data[i][c];
            }
            temp_row[c] = number;
        }
        result_data[r] = temp_row;
    }
    // return result;
}

Matrix Matrix::mul(Matrix mat){
    Matrix result = Matrix().init(this->row_size, mat.col_size);
    _mul(this, &mat, &result);
    return result;
}

std::vector<Matrix> Matrix::split_col(int count){
    if (col_size % count)
    {
        cerr << "Cant split col on col size " << col_size << " to " << count;
        exit(-1);
    }

    uint64_t length = col_size / count;
    std::vector<Matrix> result(count);
    for (size_t i = 0; i < count; i++)
    {
        Matrix matrix = Matrix(row_size, length);
        std::vector<std::vector<double>> matrix_data(row_size);
        for (size_t r = 0; r < row_size; r++)
        {
            std::vector<double> this_row(length);
            double* my_row = data[r].data();
            for (size_t c = 0; c < length; c++)
            {
                this_row[c] = my_row[c + i*length];
            }
            matrix_data[r] = this_row;
        }
        
        matrix.data = matrix_data;
        result[i].move(&matrix);
    }

    return result;
}

std::vector<Matrix> Matrix::split_row(int count){
    if (row_size % count)
    {
        cerr << "Cant split row on row size " << row_size << " to " << count;
        exit(-1);
    }

    uint64_t length = row_size / count;
    std::vector<Matrix> result(count);
    for (size_t i = 0; i < count; i++)
    {
        Matrix matrix = Matrix(length, col_size);
        std::vector<std::vector<double>> matrix_data(length);
        for (size_t r = 0; r < length; r++)
        {
            std::vector<double> this_row(col_size);
            double *my_row = data[r + i*length].data();
            // cout << data[r + i*length];
            for (size_t c = 0; c < col_size; c++)
            {
                this_row[c] = my_row[c];
            }
            matrix_data[r] = this_row;
            // cout << this_row;
        }
        matrix.data = matrix_data;
        // cout << matrix;
        result[i].move(&matrix);
    }
    
    return result;
}

Matrix Matrix::join_row(std::vector<Matrix>& matrices){
    uint64_t count = matrices.size();
    Matrix& first = matrices.front();
    uint64_t row_size = first.row_size;
    uint64_t col_size = first.col_size;
    Matrix result = Matrix().init(first.row_size * count, first.col_size);
    std::vector<std::vector<double>>& result_data = result.data;
    uint64_t result_row_size = result.row_size;
    uint64_t result_col_size = result.col_size;

    for (size_t i = 0; i < count; i++)
    {
        Matrix& matrix = matrices[i];
        std::vector<std::vector<double>>& matrix_data = matrix.data;
        // cout << matrix;
        for (size_t r = 0; r < row_size; r++)
        {
            std::vector<double>& result_row = result_data[i*row_size + r];
            std::vector<double>& matrix_row = matrix_data[r];
            // cout << matrix_row;
            for (size_t c = 0; c < result_col_size; c++)
            {
                result_row[c] = matrix_row[c];
            }
        }
    }
    return result;
}

Matrix Matrix::join_col(std::vector<Matrix>& matrices){
    uint64_t count = matrices.size();
    Matrix& first = matrices.front();
    uint64_t row_size = first.row_size;
    uint64_t col_size = first.col_size;
    Matrix result = Matrix().init(first.row_size, first.col_size * count);
    std::vector<std::vector<double>>& result_data = result.data;
    uint64_t result_row_size = result.row_size;
    uint64_t result_col_size = result.col_size;
    // cout << "row size: " << result_row_size << "\n";
    // cout << "col size: " << result_col_size << "\n";
    
    // for (size_t r = 0; r < row_size; r++)
    // {
    //     std::vector<double>& result_row = result_data[r];
    //     for (size_t i = 0; i < count; i++)
    //     {
    //         Matrix& matrix = matrices[i];
    //         std::vector<std::vector<double>>& matrix_data = matrix.data;
    //         std::vector<double>& matrix_row = matrix_data[r];
    //         uint64_t _index = i*col_size;
    //         for (size_t c = 0; c < result_col_size; c++)
    //         {
    //             result_row[_index + c] = matrix_row[c];
    //         }
    //     }
    // }

    for (size_t i = 0; i < count; i++)
    {
        Matrix& matrix = matrices[i];
        std::vector<std::vector<double>>& matrix_data = matrix.data;
        uint64_t index = i * col_size;
        // cout << matrix;
        for (size_t r = 0; r < row_size; r++)
        {
            std::vector<double>& result_row = result_data[r];
            // std::vector<double>& matrix_row = matrix_data[r];
            // double* result_row = result_data[r].data();
            double* matrix_row = matrix_data[r].data();
            // cout << matrix_row;
            // cout << i << " " << r << " " << result_row << "\n";
            for (size_t c = 0; c < col_size; c++)
            {
                result_row[c + index] = matrix_row[c];
                // cout << " on " << c + index;
            }
        }
    }
    // cout << result.data[0];
    return result;
}

std::vector<Matrix> Matrix::multi_mul(std::vector<Matrix> &left, std::vector<Matrix> &right){
    uint64_t size = left.size();
    uint64_t result_row_size = left.front().row_size;
    uint64_t result_col_size = right.front().col_size;
    std::vector<Matrix> matrices = std::vector<Matrix>(size);
    std::thread threads[size];

    for (size_t i = 0; i < size; i++)
    {
        matrices[i].move(Matrix().init(result_row_size, result_col_size));
        threads[i] = std::thread(_mul, &left[i], &right[i], &matrices[i]);
    }
    
    for (size_t i = 0; i < size; i++)
    {
        threads[i].join();
    }

    return matrices;
}

void Matrix::multi_self_add(std::vector<Matrix>& left, std::vector<Matrix>& right){
    std::thread threads[size];

    for (size_t i = 0; i < size; i++)
    {
        threads[i] = std::thread(_mul, &left[i], &right[i], &matrices[i]);
    }
    
    for (size_t i = 0; i < size; i++)
    {
        threads[i].join();
    }

    return matrices;
}

Matrix& Matrix::self_add(Matrix mat){
    if (!this->is_equal_shape(mat))
    {
        cerr << "Inavlid matrix shape for +";
        exit(-1);
    }
    vector<vector<double>> &result_data = data;
    for (size_t r = 0; r < row_size; r++)
    {
        vector<double> &result_row = result_data[r];
        vector<double> your_row = mat.data[r];
        for (size_t c = 0; c < col_size; c++)
        {
            result_row[c] += your_row[c];
        }
    }
    return *this;
};

Matrix& Matrix::self_min(Matrix mat){
    if (!this->is_equal_shape(mat))
    {
        cerr << "Inavlid matrix shape for +";
        exit(-1);
    }
    vector<vector<double>> &result_data = data;
    for (size_t r = 0; r < row_size; r++)
    {
        vector<double> &result_row = result_data[r];
        vector<double> your_row = mat.data[r];
        for (size_t c = 0; c < col_size; c++)
        {
            result_row[c] -= your_row[c];
        }
    }
    return *this;
};

Matrix& Matrix::self_mul(double number){
    for (size_t r = 0; r < row_size; r++)
    {
        std::vector<double> &row = data[r];
        for (size_t c = 0; c < col_size; c++)
        {
            row[c] *= number;
        }
    }
    return *this;
}

Matrix& Matrix::self_div(double number){
    for (size_t r = 0; r < row_size; r++)
    {
        std::vector<double> &row = data[r];
        for (size_t c = 0; c < col_size; c++)
        {
            row[c] /= number;
        }
    }
    return *this;
}

void Matrix::operator()(Matrix&& matrix){
    _move(this, (Matrix&&)matrix);
}

void _each_fast_add_row(void* _argument, int at_row, int to_row, int col_size){
    struct _for_fast *argument = (struct _for_fast*)_argument;
    std::vector<std::vector<double>> &left = argument->left->data;
    std::vector<std::vector<double>> &right = argument->right->data;
    std::vector<std::vector<double>> &result = argument->result->data;

    for (size_t r = at_row; r < to_row; r++)
    {
        std::vector<double> &left_row = left[r];
        std::vector<double> &right_row = right[r];
        std::vector<double> &result_row = result[r];
        for (size_t c = 0; c < col_size; c++)
        {
            result_row[c] = left_row[c] + right_row[c];
        }
    }
}

void _each_fast_add_col(void* _argument, int at_col, int to_col, int row_size){
    struct _for_fast *argument = (struct _for_fast*)_argument;
    std::vector<std::vector<double>> &left = argument->left->data;
    std::vector<std::vector<double>> &right = argument->right->data;
    std::vector<std::vector<double>> &result = argument->result->data;

    for (size_t r = 0; r < row_size; r++)
    {
        std::vector<double> &left_row = left[r];
        std::vector<double> &right_row = right[r];
        std::vector<double> &result_row = result[r];
        for (size_t c = at_col; c < to_col; c++)
        {
            result_row[c] = left_row[c] + right_row[c];
        }
    }
}

Matrix Matrix::fast_self_add(Matrix matrix, const int thread_count){
    if ((this->row_size != matrix.row_size) && (this->col_size != matrix.col_size))
    {
        cerr << "Invalid size for fast add!\n";
        exit(-1);
    }
    Matrix result = Matrix().init(this->row_size, matrix.col_size);
    uint64_t row_size = this->row_size;
    uint64_t col_size = matrix.col_size;
    uint64_t element_size = this->col_size;
    _for_fast argument = {
        .left = this,
        .right = &matrix,
        .result = this
    };
    std::thread threads[thread_count];
    double each_index = 1.0/double(thread_count);
    double from_index = 0.0;
    double to_index = each_index;
    for (size_t i = 0; i < thread_count; i++)
    {
        from_index = row_size * (i*each_index);
        to_index = row_size * ((i+1)*each_index);
        threads[i] = std::thread(_each_fast_add_row, (void*)(&argument), from_index, to_index, col_size);
    }
    for (size_t i = 0; i < thread_count; i++)
    {
        threads[i].join();
    }
    return result;
}

Matrix Matrix::fast_add(Matrix matrix, const int thread_count){
    if ((this->row_size != matrix.row_size) && (this->col_size != matrix.col_size))
    {
        cerr << "Invalid size for fast add!\n";
        exit(-1);
    }
    Matrix result = Matrix().init(this->row_size, matrix.col_size);
    uint64_t row_size = this->row_size;
    uint64_t col_size = matrix.col_size;
    uint64_t element_size = this->col_size;
    _for_fast argument = {
        .left = this,
        .right = &matrix,
        .result = &result
    };
    std::thread threads[thread_count];
    double each_index = 1.0/double(thread_count);
    double from_index = 0.0;
    double to_index = each_index;
    for (size_t i = 0; i < thread_count; i++)
    {
        from_index = row_size * (i*each_index);
        to_index = row_size * ((i+1)*each_index);
        threads[i] = std::thread(_each_fast_add_row, (void*)(&argument), from_index, to_index, col_size);
    }
    for (size_t i = 0; i < thread_count; i++)
    {
        threads[i].join();
    }
    return result;
}

void _each_fast_min_row(void* _argument, int at_row, int to_row, int col_size){
    struct _for_fast *argument = (struct _for_fast*)_argument;
    std::vector<std::vector<double>> &left = argument->left->data;
    std::vector<std::vector<double>> &right = argument->right->data;
    std::vector<std::vector<double>> &result = argument->result->data;

    for (size_t r = at_row; r < to_row; r++)
    {
        std::vector<double> &left_row = left[r];
        std::vector<double> &right_row = right[r];
        std::vector<double> &result_row = result[r];
        for (size_t c = 0; c < col_size; c++)
        {
            result_row[c] = left_row[c] - right_row[c];
        }
    }
}

void _each_fast_min_col(void* _argument, int at_col, int to_col, int row_size){
    struct _for_fast *argument = (struct _for_fast*)_argument;
    std::vector<std::vector<double>> &left = argument->left->data;
    std::vector<std::vector<double>> &right = argument->right->data;
    std::vector<std::vector<double>> &result = argument->result->data;

    for (size_t r = 0; r < row_size; r++)
    {
        std::vector<double> &left_row = left[r];
        std::vector<double> &right_row = right[r];
        std::vector<double> &result_row = result[r];
        for (size_t c = at_col; c < to_col; c++)
        {
            result_row[c] = left_row[c] - right_row[c];
        }
    }
}

Matrix Matrix::fast_self_min(Matrix matrix, const int thread_count){
    if ((this->row_size != matrix.row_size) && (this->col_size != matrix.col_size))
    {
        cerr << "Invalid size for fast add!\n";
        exit(-1);
    }
    Matrix result = Matrix().init(this->row_size, matrix.col_size);
    uint64_t row_size = this->row_size;
    uint64_t col_size = matrix.col_size;
    uint64_t element_size = this->col_size;
    _for_fast argument = {
        .left = this,
        .right = &matrix,
        .result = this
    };
    std::thread threads[thread_count];
    double each_index = 1.0/double(thread_count);
    double from_index = 0.0;
    double to_index = each_index;
    for (size_t i = 0; i < thread_count; i++)
    {
        from_index = row_size * (i*each_index);
        to_index = row_size * ((i+1)*each_index);
        threads[i] = std::thread(_each_fast_min_row, (void*)(&argument), from_index, to_index, col_size);
    }
    for (size_t i = 0; i < thread_count; i++)
    {
        threads[i].join();
    }
    return result;
}

Matrix Matrix::fast_min(Matrix matrix, const int thread_count){
    if ((this->row_size != matrix.row_size) && (this->col_size != matrix.col_size))
    {
        cerr << "Invalid size for fast add!\n";
        exit(-1);
    }
    Matrix result = Matrix().init(this->row_size, matrix.col_size);
    uint64_t row_size = this->row_size;
    uint64_t col_size = matrix.col_size;
    uint64_t element_size = this->col_size;
    _for_fast argument = {
        .left = this,
        .right = &matrix,
        .result = &result
    };
    std::thread threads[thread_count];
    double each_index = 1.0/double(thread_count);
    double from_index = 0.0;
    double to_index = each_index;
    for (size_t i = 0; i < thread_count; i++)
    {
        from_index = row_size * (i*each_index);
        to_index = row_size * ((i+1)*each_index);
        threads[i] = std::thread(_each_fast_min_row, (void*)(&argument), from_index, to_index, col_size);
    }
    for (size_t i = 0; i < thread_count; i++)
    {
        threads[i].join();
    }
    return result;
}

void _each_fast_mul_row(void* _argument, int at_row, int to_row, int col_size, int element_size){
    struct _for_fast *argument = (struct _for_fast*)_argument;
    std::vector<std::vector<double>> &left = argument->left->data;
    std::vector<std::vector<double>> &right = argument->right->data;
    std::vector<std::vector<double>> &result = argument->result->data;
    for (size_t r = at_row; r < to_row; r++)
    {
        double* left_row = left[r].data();
        double* result_index = result[r].data();
        for (size_t c = 0; c < col_size; c++)
        {
            double number = 0.0;
            for (size_t i = 0; i < element_size; i++)
            {
                number += left_row[i] * right[i][c];
            }
            result_index[c] = number;
        }
    }
}

void _each_fast_mul_col(void* _argument, int at_col, int to_col, int row_size, int element_size){
    struct _for_fast *argument = (struct _for_fast*)_argument;
    std::vector<std::vector<double>> &left = argument->left->data;
    std::vector<std::vector<double>> &right = argument->right->data;
    std::vector<std::vector<double>> &result = argument->result->data;
    for (size_t r = 0; r < row_size; r++)
    {
        double* left_row = left[r].data();
        double* result_index = result[r].data();
        for (size_t c = at_col; c < to_col; c++)
        {
            double number = 0.0;
            for (size_t i = 0; i < element_size; i++)
            {
                number += left_row[i] * right[i][c];
            }
            result_index[c] = number;
        }
    }
}

Matrix Matrix::fast_mul(Matrix matrix, const int thread_count){
    Matrix result = Matrix().init(this->row_size, matrix.col_size);
    uint64_t row_size = this->row_size;
    uint64_t col_size = matrix.col_size;
    uint64_t element_size = this->col_size;
    _for_fast argument = {
        .left = this,
        .right = &matrix,
        .result = &result
    };
    std::thread threads[thread_count];
    double each_index = 1.0/double(thread_count);
    double from_index = 0.0;
    double to_index = each_index;
    for (size_t i = 0; i < thread_count; i++)
    {
        from_index = row_size * (i*each_index);
        to_index = row_size * ((i+1)*each_index);
        threads[i] = std::thread(_each_fast_mul_row, (void*)(&argument), from_index, to_index, col_size, element_size);
    }
    for (size_t i = 0; i < thread_count; i++)
    {
        threads[i].join();
    }
    return result;
}

// Matrix Matrix::fast_mul(Matrix){
//     fast_mul()
// }

bool Matrix::is_equal_shape(Matrix mat){
    return((row_size == mat.row_size) && (col_size == mat.col_size));
};

bool Matrix::is_square(){
    return row_size == col_size;
};

Matrix& Matrix::fill_force(vector<vector<double>> _data){
    int64_t this_row_size = _data.size();
    int64_t this_col_size = _data[0].size();

    for (size_t i = 1; i < this_row_size; i++)
    {
        if (this_col_size != _data[i].size())
        {
            cerr << "Invalid column size for fill!\n";
            exit(-1);
        }
    }
    row_size = this_row_size;
    col_size = this_col_size;
    data = _data;
    return *this;
}

Matrix& Matrix::fill_random(double low, double high){
    //LO + static_cast <float> (rand()) /( static_cast <float> (RAND_MAX/(HI-LO)));
    srand(time(0));
    // srand(rand());
    // cout << "filling";
    for (size_t r = 0; r < row_size; r++)
    {
        vector<double> &row = this->data[r];
        for (size_t c = 0; c < col_size; c++)
        {
            // cout << low + static_cast <float> (rand()) /( static_cast <float> (RAND_MAX/(high-low))) << "\n";
            row[c] = low + static_cast <double> (rand()) /( static_cast <double> (RAND_MAX/(high-low)));
            // cout << row[c] << "\n";
            // row[c] = low;
        }
        // cout << row << "\n";
        srand(rand() + rand());
    }
    // cout << data[0];
    return *this;
}

Matrix& Matrix::fill_diagonal(double diagonal, double rest){
    if (!is_square())
    {
        cerr << "Fill diagonal must be square matrix!";
        exit(-1);
    }
    
    for (size_t r = 0; r < col_size; r++)
    {
        this_row_fill(data[r], rest);
        data[r][r] = diagonal;
    }
    
    return *this;
}

Matrix& Matrix::resquare_diagonal(double diagonal){
    vector<double> ori;
    ori.resize(col_size);
    this_row_fill(ori, 0.0);
    for (size_t i = row_size; i < col_size; i++)
    {
        vector<double> temp = this_row_duplicate(ori);
        temp[i] = diagonal;
        data.push_back(temp);
    }
    
    row_size = col_size;
    return *this;
}

Matrix& Matrix::resize_square(uint64_t size){
	if (col_size < size)
	{
		int start_index = row_size-1;
		for (size_t i = 0; i < row_size; i++)
		{
			data[i].resize(size);
			if(i > start_index){
				data[i][i] = 1.0;
			}
		}
	}else if (col_size > size)
	{
		for (size_t i = 0; i < col_size; i++)
		{
			data[i].resize(size);
		}
	}

	if (row_size < size)
	{
		for (size_t i = row_size; i < size; i++)
		{
			std::vector<double> vector = std::vector<double>(size);
			vector[i] = 1.0;
			data.push_back(vector);
		}
	}else if (row_size > size)
	{
		pop_row(size - row_size);
	}

	col_size = size;
	row_size = size;
	return *this;
}

void Matrix::pop_row(int count){
    if (count > row_size)
    {
        cerr << "Unable to pop matrix!\n";
        exit(-1);
    }
    double first = data[0][0];
    for (size_t i = row_size-1; i > row_size-count-1; i--)
    {
        // cout << i << "\n";
        data[i].clear();
        data.pop_back();
    }
    data[0][0] = first;
    row_size -= count;
}

std::ostream& operator<<(std::ostream& os, Matrix mat){
    os << "[row size: " << mat.row_size << ", col size: " << mat.col_size << ", data: {";
    os << std::fixed;
    vector<double> &row = mat.data[0];
    os << "{" << row[0];
    for (size_t c = 1; c < mat.col_size; c++)
    {
        os << ", " << row[c];
    }
    os << "}";

    for (size_t r = 1; r < mat.row_size; r++)
    {
        vector<double> &row = mat.data[r];
        os << ", {" << row[0];
        for (size_t c = 1; c < mat.col_size; c++)
        {
            os << ", " << row[c];
        }
        os << "}";
    }
    
    os << "}]\n";
    return os;
};

std::ostream& operator<<(std::ostream& os, vector<double> data){
    os << "{";
    for (size_t i = 0; i < data.size()-1; i++)
    {
        os << data[i] << ", ";
    }
    os << data.back() << "}";
    return os;
};

// Matrix Matrix::operator=(vector<vector<double>> _data){
//     int64_t this_col_size = _data[0].size();
//     for (size_t i = 1; i < this_col_size; i++)
//     {
//         if (this_col_size != _data[i].size())
//         {
//             cerr << "Invalid size in assigment!\n";
//             return;
//         }
//     }
//     this->row_size = _data.size();
//     this->col_size = this_col_size;
//     this->data = _data;
// }

static vector<double> this_row_duplicate(vector<double>& target){
    vector<double> new_row;
    new_row.resize(target.size());
    for (size_t i = 0; i < target.size(); i++)
    {
        new_row[i] = target[i];
    }
    return new_row;
}

static vector<double>& this_row_fill(vector<double>& target, double number){
    for (size_t i = 0; i < target.size(); i++)
    {
        target[i] = number;
    }
    return target;
}

static vector<double>& this_row_plus(vector<double>& target, vector<double>source){
    if (target.size() != source.size())
    {
        std::cerr << "Invalid size for target and source!";
        return target;
    }

    for (size_t i = 0; i < target.size(); i++)
    {
        target[i] += source[i];
    }
    
    return target;
}

static vector<double>& this_row_min(vector<double>& target, vector<double>source){
    if (target.size() != source.size())
    {
        std::cerr << "Invalid size for target and source!";
        return target;
    }

    for (size_t i = 0; i < target.size(); i++)
    {
        target[i] -= source[i];
    }
    
    return target;
}

static vector<double>& this_row_mul(vector<double>& target, vector<double>source){
    if (target.size() != source.size())
    {
        std::cerr << "Invalid size for target and source!";
        return target;
    }

    for (size_t i = 0; i < target.size(); i++)
    {
        target[i] *= source[i];
    }
    
    return target;
}

static vector<double>& this_row_mul(vector<double>& target, double number){
    for (size_t i = 0; i < target.size(); i++)
    {
        target[i] *= number;
    }
    
    return target;
}

static vector<double>& this_row_div(vector<double>& target, vector<double>source){
    if (target.size() != source.size())
    {
        std::cerr << "Invalid size for target and source!";
        return target;
    }

    for (size_t i = 0; i < target.size(); i++)
    {
        target[i] /= source[i];
    }
    
    return target;
}

static vector<double>& this_row_div(vector<double>& target, double number){
    for (size_t i = 0; i < target.size(); i++)
    {
        target[i] /= number;
    }
    return target;
}
