extends RefCounted
class_name Transformer

var VECTOR_SIZE:int
var INPUT_SIZE:int
var OUTPUT_SIZE:int

### Learnable
var Encode_Query:Matrix
var Encode_Key:Matrix
var Encode_Value:Matrix

var Decode1_Query:Matrix
var Decode1_Key:Matrix
var Decode1_Value:Matrix

var Decode2_Query:Matrix
var Decode2_Key:Matrix
var Decode2_Value:Matrix

var Words_input_id:Dictionary
var Words_output_id:Dictionary
var Words_encode_vector:Matrix
var Words_decode_vector:Matrix
var Words_output_vector:Matrix

var PE_cache:Matrix
#####

var Encode_Result:Matrix
var Decode1_Result:Matrix
var Decode2_Result:Matrix

var decoder_result:PackedStringArray
var decoder_input:PackedInt64Array
var decoder_input_vector:Matrix

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
	var matrix:Matrix = Matrix.new()
	matrix.fill_force(w)
	var matrix_data = matrix._to_dict()
	
	var words_input_id:Dictionary
	var words_input_vector:Array[PackedFloat64Array]
	words_input_vector.resize(input_size)
	for i in range(input_size):
		words_input_vector[i] = array.duplicate()
		words_input_id[ input[i] ] = i
	var words_input_matrix:Matrix = Matrix.new().fill_force(words_input_vector)
	
	var words_output_id:Dictionary
	var words_output_vector:Array[PackedFloat64Array]
	words_output_vector.resize(output_size)
	for i in range(output_size):
		words_output_vector[i] = array.duplicate()
		words_output_id[ output[i] ] = i
	var words_output_matrix:Matrix = Matrix.new().fill_force(words_output_vector)
	
	
	var data = {
		"encode_q" : matrix_data,
		"encode_k" : matrix_data,
		"encode_v" : matrix_data,
		"decode1_q" : matrix_data,
		"decode1_k" : matrix_data,
		"decode1_v" : matrix_data,
		"decode2_q" : matrix_data,
		"decode2_k" : matrix_data,
		"decode2_v" : matrix_data,
		"vector_size" : vector_size,
		"input_size" : input_size,
		"output_size" : output_size,
		"words_input_id" : words_input_id,
		"words_output_id" : words_output_id,
		"words_encode_vector" : words_input_matrix._to_dict(),
		"words_decode_vector" : words_output_matrix._to_dict(),
		"words_output_vector" : Matrix.new().fill_force(words_output_vector).transpose()._to_dict(),
		"pe_cache" : Matrix.new().init(0, vector_size)._to_dict()
	}
	
	file.store_string(
		JSON.stringify(data, "\t", false, true)
	)
	file.close()
	return true

func _init():
	decoder_input_vector = Matrix.new().init(1, VECTOR_SIZE)

func save(path:String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	var data:Dictionary = {
		"encode_q" : Encode_Query._to_dict(),
		"encode_k" : Encode_Key._to_dict(),
		"encode_v" : Encode_Value._to_dict(),
		"decode1_q" : Decode1_Query._to_dict(),
		"decode1_k" : Decode1_Key._to_dict(),
		"decode1_v" : Decode1_Value._to_dict(),
		"decode2_q" : Decode2_Query._to_dict(),
		"decode2_k" : Decode2_Key._to_dict(),
		"decode2_v" : Decode2_Value._to_dict(),
		"vector_size" : VECTOR_SIZE,
		"input_size" : INPUT_SIZE,
		"output_size" : OUTPUT_SIZE,
		"words_input_id" : Words_input_id,
		"words_output_id" : Words_output_id,
		"words_encode_vector" : Words_encode_vector._to_dict(),
		"words_decode_vector" : Words_decode_vector._to_dict(),
		"words_output_vector" : Words_output_vector._to_dict(),
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
	Encode_Query = Matrix.new().load_from_dict(data["encode_q"])
	Encode_Key = Matrix.new().load_from_dict(data["encode_k"])
	Encode_Value = Matrix.new().load_from_dict(data["encode_v"])
	Decode1_Query = Matrix.new().load_from_dict(data["decode1_q"])
	Decode1_Key = Matrix.new().load_from_dict(data["decode1_k"])
	Decode1_Value = Matrix.new().load_from_dict(data["decode1_v"])
	Decode2_Query = Matrix.new().load_from_dict(data["decode2_q"])
	Decode2_Key = Matrix.new().load_from_dict(data["decode2_k"])
	Decode2_Value = Matrix.new().load_from_dict(data["decode2_v"])
	Words_input_id = data["words_input_id"]
	Words_output_id = data["words_output_id"]
	Words_encode_vector = Matrix.new().load_from_dict(data["words_encode_vector"])
	Words_decode_vector = Matrix.new().load_from_dict(data["words_decode_vector"])
	Words_output_vector = Matrix.new().load_from_dict(data["words_output_vector"])
	PE_cache = Matrix.new().load_from_dict(data["pe_cache"])

func encode(input:String):
	var input_split = split_string(input)
	var input_vector = input_words_to_vectors( input_split )
	var pos_encoding = positional_encoding(input_vector.row_size)
	
	input_vector.add_self(pos_encoding)
	
	var input_query = input_vector.mul_t(Encode_Query)
	var input_key = input_vector.mul_t(Encode_Key)
	var input_value = input_vector.mul_t(Encode_Value)
	Encode_Result = \
	input_query.mul_t(input_key) \
	.div_self_by_number(sqrt(VECTOR_SIZE)).softmax() \
	.mul(input_value)
#	input_value.mul_t(
#		input_query.transpose().mul(input_key).div_self_by_number(sqrt(VECTOR_SIZE)).softmax()
#	).add_row()
	return Encode_Result

func decode(next_input:String):
	decoder_result.append(next_input)
	
	var input_vector = output_words_to_vectors(decoder_result)
	
	var pos_encoding = positional_encoding(input_vector.row_size)
	
	input_vector.add_self(pos_encoding)
	
	var input_query = input_vector.mul_t(Decode1_Query)
	var input_key = input_vector.mul_t(Decode1_Key)
	var input_value = input_vector.mul_t(Decode1_Value)
	
	Decode1_Result = input_value.mul_t(
		input_query.transpose().mul(input_key).self_mask_topright(-INF).div_self_by_number(sqrt(VECTOR_SIZE)).softmax()
	).add_row()
	
	input_query = Decode1_Result.mul_t(Decode2_Query)
	input_key = Encode_Result.mul_t(Decode2_Key)
	input_value = Encode_Result.mul_t(Decode2_Value)
	
	return input_query.mul_t(input_key)
	
	Decode2_Result = input_value.mul_t(
		input_query.mul_t(input_key).div_self_by_number(sqrt(VECTOR_SIZE)).softmax()
	).add_row()
	
	return Decode2_Result

func input_words_to_vectors(split:PackedStringArray):
	var result:Array[PackedFloat64Array]
	var matrix:Matrix = Matrix.new()
	for s in split:
		result.append( Words_encode_vector.data[Words_input_id[s]] as PackedFloat64Array )
	matrix.fill_force(result)
	return matrix

func output_words_to_vectors(split:PackedStringArray):
	var result:Array[PackedFloat64Array]
	var matrix:Matrix = Matrix.new()
	for s in split:
		result.append( Words_decode_vector.data[Words_output_id[s]] as PackedFloat64Array )
	matrix.fill_force(result)
	return matrix

func input_words_to_ids(split:PackedStringArray):
	var result:PackedInt64Array
	result.resize(split.size())
	for s in range(split.size()):
		result[s] = Words_input_id[split[s]]
	return result

func output_words_to_ids(split:PackedStringArray):
	var result:PackedInt64Array
	result.resize(split.size())
	for s in range(split.size()):
		result[s] = Words_output_id[split[s]]
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
