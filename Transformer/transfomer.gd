extends RefCounted
class_name Transformer

var VECTOR_SIZE:int
var INPUT_SIZE:int
var OUTPUT_SIZE:int
var Query
var Key
var Value
var Words_encode_id
var Words_encode_vector
var Words_decode_id
var Words_decode_vector
var Words_output_id
var Words_output_vector

static func create(path:String, vector_size:int, input:Array, output:Array):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var input_size:int = input.size()
	var output_size:int = output.size()
	var w:Array[PackedFloat64Array]
	var array:PackedFloat64Array
	w.resize(vector_size)
	array.resize(vector_size)
	array.fill(0.9)
	for i in range(vector_size):
		w[i] = array.duplicate()
	var matrix:Matrix = Matrix.new()
	matrix.fill_force(w)
	var matrix_data = matrix._to_dict()
	
	var words_input_id:Dictionary
	var words_input_vector:Array
	words_input_vector.resize(input_size)
	for i in range(input_size):
		words_input_vector[i] = array.duplicate()
		words_input_id[ input[i] ] = i
	
	var words_output_id:Dictionary
	var words_output_vector:Array
	words_output_vector.resize(output_size)
	for i in range(output_size):
		words_output_vector[i] = array.duplicate()
		words_output_id[ output[i] ] = i
	
	
	var data = {
		"q" : matrix_data,
		"k" : matrix_data,
		"v" : matrix_data,
		"vector_size" : vector_size,
		"input_size" : input_size,
		"output_size" : output_size,
		"words_encode_id" : words_input_id,
		"words_encode_vector" : words_input_vector,
		"words_decode_id" : words_output_id,
		"words_decode_vector" : words_output_vector,
		"words_output_id" : words_output_id,
		"words_output_vector" : words_output_vector
	}
	
	file.store_string(
		JSON.stringify(data, "\t", false, true)
	)
	file.close()

func load(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var data:Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	Query = Matrix.new().load_from_dict(data["q"])
	Key = Matrix.new().load_from_dict(data["k"])
	Value = Matrix.new().load_from_dict(data["v"])
	Words_encode_id = data["words_encode_id"]
	Words_encode_vector = data["words_encode_vector"]
	VECTOR_SIZE = data["vector_size"]
	INPUT_SIZE = data["input_size"]
	OUTPUT_SIZE = data["output_size"]

func encode(input:String):
	var input_split = split_string(input)
	var input_vector = words_to_vectors( input_split )
	var pos_encoding = positional_encoding(input_vector.row_size)
	
	input_vector.add_self(pos_encoding)
	
	var input_query = input_vector.mul_t(Query)
	var input_key = input_vector.mul_t(Key)
	var input_value = input_vector.mul_t(Value)
	
	return input_query.mul_t(input_key).div_self_by_number(sqrt(VECTOR_SIZE)).softmax().mul(input_value)

func words_to_vectors(split:PackedStringArray):
	var result:Array[PackedFloat64Array]
	var matrix:Matrix = Matrix.new()
	for s in split:
		result.append( Words_encode_vector[Words_encode_id[s]] as PackedFloat64Array )
	matrix.fill_force(result)
	return matrix

func words_to_ids(split:PackedStringArray):
	var result:PackedInt64Array
	result.resize(split.size())
	for s in range(split.size()):
		result[s] = Words_encode_id[split[s]]
	return result

func split_string(string:String):
	var result:PackedStringArray
	var splits = string.split(" ", false)
	
	for split in splits:
		var s = split
		if s[-1] in [","]:
			s = s.substr(0, -2)
		result.append(s)
	return result

func positional_encoding(length:int):
	var matrix:Matrix = Matrix.new()
	var results:Array[PackedFloat64Array]
	results.resize(length)
	for i in range(length):
		var result:PackedFloat64Array
		result.resize(VECTOR_SIZE)
		for d in range(VECTOR_SIZE/2):
			result[d*2] = sin( i / pow(10000, (d/float(VECTOR_SIZE))) )
			result[d*2+1] = cos( i / pow(10000, (d/float(VECTOR_SIZE))) )
		results[i] = result
	return matrix.fill_force(results)
