extends RefCounted
class_name SimpleTransformer


### Constant
var VECTOR_SIZE:int
var INPUT_SIZE:int
var OUTPUT_SIZE:int
#####

### Learnable
var Query:Matrix
var Key:Matrix
var Value:Matrix

var Input_id
var Output_id
var Input_vector:Matrix
var Output_vector:Matrix
###

var PE_cache
var output_keys:PackedStringArray

var result:Array

static func create(path:String, vector_size:int, input:Array, output:Array):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var input_size:int = input.size()
	var output_size:int = output.size()
	var w:Array[PackedFloat64Array]
	var array:PackedFloat64Array
	w.resize(vector_size)
	array.resize(vector_size)
	array.fill(0.1)
	for i in range(randi_range(0, vector_size)):
		array[i] = randf_range(-0.9, 0.9)
	for i in range(vector_size):
		(array as Array).shuffle()
		w[i] = array.duplicate()
		array[i] = randf_range(-0.9, 0.9)
	var matrix:Matrix = Matrix.new()
	matrix.fill_force(w)
	var matrix_data = matrix._to_dict()
	
	var input_id:Dictionary
	var input_vector:Array[PackedFloat64Array]
	input_vector.resize(input_size)
	for i in range(input_size):
		input_vector[i] = array.duplicate()
		input_id[ input[i] ] = i
	var input_matrix:Matrix = Matrix.new().fill_force(input_vector)
	
	var output_id:Dictionary
	var output_vector:Array[PackedFloat64Array]
	output_vector.resize(output_size)
	for i in range(output_size):
		output_vector[i] = array.duplicate()
		output_id[ output[i] ] = i
	var output_matrix:Matrix = Matrix.new().fill_force(output_vector)
	
	var data:Dictionary = {
		"query" : matrix.shufle().duplicate()._to_dict(),
		"key" : matrix.shufle().duplicate()._to_dict(),
		"value" : matrix.shufle().duplicate()._to_dict(),
		"vector_size" : vector_size,
		"input_size" : input_size,
		"output_size" : output_size,
		"input_id" : input_id,
		"output_id" : output_id,
		"input_vector" : input_matrix._to_dict(),
		"output_vector" : output_matrix._to_dict(),
		"pe_cache" : Matrix.new().init(0, vector_size)._to_dict()
	}
	
	file.store_string(
		JSON.stringify(data, "\t", false)
	)
	
	file.close()

func save(path:String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	var data:Dictionary = {
		"query" : Query._to_dict(),
		"key" : Key._to_dict(),
		"value" : Value._to_dict(),
		"vector_size" : VECTOR_SIZE,
		"input_size" : INPUT_SIZE,
		"output_size" : OUTPUT_SIZE,
		"input_id" : Input_id,
		"output_id" : Output_id,
		"input_vector" : Input_vector._to_dict(),
		"output_vector" : Output_vector._to_dict(),
		"pe_cache" : PE_cache._to_dict()
	}
	
	file.store_string(
		JSON.stringify(data, "\t", false)
	)
	
	file.close()

func load(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var data:Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	
	VECTOR_SIZE = data["vector_size"]
	INPUT_SIZE = data["input_size"]
	OUTPUT_SIZE = data["output_size"]
	Query = Matrix.new().load_from_dict(data["query"])
	Key = Matrix.new().load_from_dict(data["key"])
	Value = Matrix.new().load_from_dict(data["value"])
	Input_id = data["input_id"]
	Output_id = data["output_id"]
	Input_vector = Matrix.new().load_from_dict(data["input_vector"])
	Output_vector = Matrix.new().load_from_dict(data["output_vector"])
	PE_cache = Matrix.new().load_from_dict(data["pe_cache"])
	
	output_keys = Output_id.keys()

func forward(input:String):
	var input_split = split_string(input)
#	sequence_length = input_split.size()
	var input_vector = input_words_to_vectors( input_split )
#	return input_vector
	var pos_encoding = positional_encoding(input_vector.row_size)
	
	input_vector.add_self(pos_encoding)
	
	var input_query = input_vector.mul(Query)
	var input_key = input_vector.mul(Key)
	var input_value = input_vector.mul(Value)
	var output = \
	input_query.mul_t(input_key).div_self_by_number(sqrt(VECTOR_SIZE)).softmax().mul(input_value)
	
#	print("before softmax")
	output = output.mul_t( Output_vector ).softmax()
#	print("after softmax")
	
	var result:PackedStringArray
	result.resize(output.row_size)
	for i in range(output.row_size):
		result[i] = output_keys[ highest( output.data[i] ) ]
	return result

func backward(input:String, expected:String):
	var output_vector = output_words_to_vectors( expected.split(" ") )
	
	return output_vector

func input_words_to_vectors(split:PackedStringArray):
	var result:Array[PackedFloat64Array]
	var matrix:Matrix = Matrix.new()
	for s in split:
		result.append( Input_vector.data[Input_id[s]] as PackedFloat64Array )
	matrix.fill_force(result)
	return matrix

func output_words_to_vectors(split:PackedStringArray):
	var result:Array[PackedFloat64Array]
	var matrix:Matrix = Matrix.new()
	for s in split:
		result.append( Output_vector.data[Output_id[s]] as PackedFloat64Array )
	matrix.fill_force(result)
	return matrix

func split_string(string:String):
	var result:PackedStringArray
	var splits = string.split(" ", false)
	
	for split in splits:
		var s = split
		if s[-1] == ",":
			result.append(",")
			s = s.substr(0, -2)
		result.append(s)
	return result

func positional_encoding(length:int):
	if length > PE_cache.row_size:
		PE_cache.self_concat_row( 
			generate_positional_encoding( PE_cache.row_size, length ) 
		)
		return PE_cache
	else:
		return PE_cache.sub_row(0, length)

func generate_positional_encoding(from:int, to:int):
	var matrix:Matrix = Matrix.new()
	var results:Array[PackedFloat64Array]
	results.resize(to - from)
	for i in range(from, to):
		var result:PackedFloat64Array
		result.resize(VECTOR_SIZE)
		for d in range(VECTOR_SIZE/2):
			result[d*2] = sin( i / pow(10000, (d/float(VECTOR_SIZE))) )
			result[d*2+1] = cos( i / pow(10000, (d/float(VECTOR_SIZE))) )
		results[i] = result
	return matrix.fill_force(results)

func highest(numbers:PackedFloat64Array)->int:
	var highest:int = 0
	for i in range(numbers.size()):
		if numbers[highest] < numbers[i]:
			highest = i
	return highest
