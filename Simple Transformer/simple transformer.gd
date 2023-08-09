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
	var matrix:Matrix = Matrix.new().init(vector_size, vector_size).self_randomize(-5.0, 5.0)
	
	var input_id:Dictionary
	for i in range(input_size):
		input_id[ input[i] ] = i
	var input_matrix:Matrix = Matrix.new().init(input_size, vector_size).self_randomize(-2.0, 2.0)
	
	var output_id:Dictionary
	for i in range(output_size):
		output_id[ output[i] ] = i
	var output_matrix:Matrix = Matrix.new().init(output_size, vector_size).self_randomize(-2.0, 2.0)
	
	var data:Dictionary = {
		"query" : matrix.self_randomize(-2.0, 2.0).duplicate()._to_dict(),
		"key" : matrix.self_randomize(-2.0, 2.0).duplicate()._to_dict(),
		"value" : matrix.self_randomize(-2.0, 2.0).duplicate()._to_dict(),
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
	clean()
	var input_split = split_string(input)
	var input_id = input_words_to_ids(input_split)
	self.result.append(input_id)
	
	var input_vector = input_ids_to_vectors( input_id )
	self.result.append(input_vector.duplicate())
	
	var pos_encoding = positional_encoding(input_vector.row_size)
	input_vector.add_self(pos_encoding)
	self.result.append(input_vector.duplicate())
	
	var input_query = input_vector.mul(Query)
	var input_key = input_vector.mul(Key)
	var input_value = input_vector.mul(Value)
	self.result.append([input_query, input_key, input_value])
	
	var s = input_query.mul_t(input_key).div_self_by_number(sqrt(VECTOR_SIZE)).softmax()
	self.result.append(s)
	
	var attention = s.mul(input_value).add(input_vector)
	
#	print("before softmax")
	var output = attention.mul_t( Output_vector ).softmax()
	self.result.append(output)
#	print("after softmax")
	
	var output_id:PackedInt64Array
	output_id.resize(output.row_size)
	var result:PackedStringArray
	result.resize(output.row_size)
	for i in range(output.row_size):
		var id = highest(output.data[i])
		output_id[i] = id
		result[i] = output_keys[ id ]
	self.result.append(output_id)
	return result

func backward(input:String, expected:String, rate:float = 0.1):
	var forward_result = forward(input)
	var output_split = expected.split(" ")
	var output_vector = output_words_to_vectors( output_split )
	
	var input_id:PackedInt64Array = self.result[0]
	var input_vector:Matrix = self.result[1]
	var input_vector_pe:Matrix = self.result[2]
	var input_query:Matrix = self.result[3][0]
	var input_key:Matrix = self.result[3][1]
	var input_value:Matrix = self.result[3][2]
	var s:Matrix = self.result[4]
	var s_d:Matrix = s.derivative_softmax()
	var output:Matrix = self.result[5]
	var output_d:Matrix = output.derivative_softmax()
	var output_id:PackedInt64Array = self.result[6]
#	print(output_id)
#	print(output.derivative_softmax())
	var expected_output:Matrix = generate_output( output_split )
	var error:Matrix = output.min(expected_output)
	
	rate = 0.1
	var new_wQ = input_vector_pe.transpose().mul( (error.mul2(output_d)).mul(Output_vector).mul_t(input_value).mul2(s_d).mul(input_key) )
	new_wQ.mul_self_by_number(rate)
	Query.min_self(new_wQ)

	var new_wK = (error.mul2(output_d)).mul(Output_vector).mul_t(input_value).mul2(s_d).mul(input_vector_pe).transpose().mul(input_query)
	new_wK.mul_self_by_number(rate)
	Key.min_self(new_wK)

	var new_wV = input_vector_pe.transpose().mul_t(s).mul(error.mul2(output_d)).mul( Output_vector )#
	new_wV.mul_self_by_number(rate)
	Value.min_self(new_wV)
	
	var new_wO = error.mul2(output_d).transpose().mul( s.mul(input_value) )
#	var new_wO = s.mul(input_value).transpose().mul(error.mul2(output_d)).transpose()
	new_wO.mul_self_by_number(0.1)
	Output_vector.min_self(new_wO)
#	print(new_wO)
	
	var new_wI1 = (error.mul2(output_d)).mul(Output_vector).mul_t(input_value).mul2(s_d).mul(input_key).mul_t(Query)
	var new_wI2 = (error.mul2(output_d)).mul(Output_vector).mul_t(input_value).mul2(s_d).transpose().mul(input_query).mul_t(Key)
	var new_wI3 = s.transpose().mul(error.mul2(output_d)).mul(Output_vector).mul_t(Value)
	var new_wI = new_wI1.add(new_wI2).add(new_wI3).mul_self_by_number(0.1)
	new_wI.mul_self_by_number(0.1)
	for i in range(input_id.size()):
		Input_vector.min_self_selected_row( new_wI.data[i], input_id[i] )
	
#	print(new_wO)
	return true

func clean()->void:
	self.result.clear()

func input_ids_to_vectors(ids:PackedInt64Array):
	var size:int = ids.size()
	var matrix:Matrix = Matrix.new()
	var result:Array[PackedFloat64Array]
	result.resize(size)
	for i in range(size):
		result[i] = Input_vector.data[i] as PackedFloat64Array
	matrix.fill_force(result)
	return matrix

func input_words_to_ids(split:PackedStringArray)->PackedInt64Array:
	var size:int = split.size()
	var result:PackedInt64Array
	result.resize(size)
	for i in range(size):
		result[i] = Input_id[split[i]]
	return result

func input_words_to_vectors(split:PackedStringArray)->Matrix:
	var result:Array[PackedFloat64Array]
	var matrix:Matrix = Matrix.new()
	for s in split:
		result.append( Input_vector.data[Input_id[s]] as PackedFloat64Array )
	matrix.fill_force(result)
	return matrix

func output_ids_to_vectors(ids:PackedInt64Array):
	var size:int = ids.size()
	var matrix:Matrix = Matrix.new()
	var result:Array[PackedFloat64Array]
	result.resize(size)
	for i in range(size):
		result[i] = Output_vector.get_col(ids[i]) as PackedFloat64Array
	matrix.fill_force(result)
	return matrix

func output_words_to_ids(split:PackedStringArray)->PackedInt64Array:
	var size:int = split.size()
	var result:PackedInt64Array
	result.resize(size)
	for i in range(size):
		result[i] = Output_id[split[i]]
	return result

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

func generate_output(split:PackedStringArray):
	var count = split.size()
	var result:Matrix = Matrix.new().init(count, OUTPUT_SIZE)
	var array:Array[PackedFloat64Array]
	array.resize(count)
	for i in range(count):
		var row:PackedFloat64Array
		row.resize(OUTPUT_SIZE)
		row[ self.Output_id[ split[i] ] ] = 1
		array[i] = row
	result.fill_force(array)
	return result

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
		results[i - from] = result
	return matrix.fill_force(results)

func highest(numbers:PackedFloat64Array)->int:
	var highest:int = 0
	for i in range(numbers.size()):
		if numbers[highest] < numbers[i]:
			highest = i
	return highest
