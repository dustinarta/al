@tool
extends RefCounted
class_name WEM2

"""
Data Structure
{
	embedding:Matrix
	vector_size:int
	word_dict:Dictionary
	pe_cache:Matrix
}

"""

var word_dict:Dictionary
var embedding:Matrix
var SEQUENCE_LENGTH:int
var VECTOR_SIZE:int
var PE_cache:Matrix

var _learning_rate
var _init_weight_range:float = 0.1
var _input_as_id:PackedInt64Array
var _forward_result:Array
var _backward_result:Array
var _path:String

func _init():
	pass

func init(vector_size:int, sequence_length:int = 20):
	word_dict = { "<p>": 0 }
	SEQUENCE_LENGTH = sequence_length
	VECTOR_SIZE = vector_size
	var limit:float = 1.0
	embedding = Matrix.new().init(1, VECTOR_SIZE).self_randomize(-limit, limit)#.init_box_muller(0, _init_weight_range)#
#	embedding.self_activation_normalization()
#	embedding.self_minmax_normalization()
	PE_cache = generate_positional_encoding(0, sequence_length)
	_learning_rate = 0.01/pow(VECTOR_SIZE, 2.0)

func append_word(split:PackedStringArray):
	var new_word_count:int = 0
	for s in split:
		if word_dict.has(s):
			continue
		else:
			word_dict[s] = word_dict.size()
			new_word_count += 1
	if new_word_count != 0:
		var new_matrix = Matrix.new().init(new_word_count, VECTOR_SIZE)
		var limit:float = 1.0
		new_matrix.self_randomize(-limit, limit)
#		new_matrix.init_box_muller(0, _init_weight_range)
		print(new_matrix.row_size)
		print(embedding.row_size)
		embedding.self_append_rows(new_matrix.data)
		embedding.self_minmax_normalization()

static func init_from_dict(data:Dictionary)->WEM2:
	var wem = WEM2.new()
	wem.SEQUENCE_LENGTH = data["sequence_length"]
	wem.VECTOR_SIZE = data["vector_size"]
	wem._learning_rate = 0.01/pow(wem.VECTOR_SIZE, 2.0)
	wem.word_dict = data["word_dict"]
	wem.embedding = Matrix.new()
	wem.embedding.load_from_dict(data["embedding"])
	wem.PE_cache = Matrix.new()
	wem.PE_cache.load_from_dict(data["pe_cache"])
	return wem

func is_empty()->bool:
	return word_dict.is_empty()

func to_dict()->Dictionary:
	return {
		"sequence_length": SEQUENCE_LENGTH,
		"vector_size": VECTOR_SIZE,
		"word_dict": word_dict,
		"embedding": embedding.to_dict(),
		"pe_cache": PE_cache.to_dict()
	}

func save(path:String):
	var data:Dictionary = to_dict()
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(
		JSON.stringify(
			data, "\t", false, true
		)
	)
	f.close()

func load(path:String):
	var f = FileAccess.open(path, FileAccess.READ)
	var data:Dictionary = JSON.parse_string(
		f.get_as_text()
	)
	SEQUENCE_LENGTH = data["sequence_length"]
	VECTOR_SIZE = data["vector_size"]
	word_dict = data["word_dict"]
	embedding = Matrix.new()
	embedding.load_from_dict(data["embedding"])
	PE_cache = Matrix.new()
	PE_cache.load_from_dict(data["pe_cache"])
	return self

func forward(inputs:PackedInt64Array, sequence_length:int = SEQUENCE_LENGTH):
	var size:int = inputs.size()
	var output:Array[PackedFloat64Array]
	output.resize(sequence_length)
	_input_as_id = []
	_input_as_id.resize(sequence_length)
	for i in range(size):
		output[i] = embedding.data[inputs[i]].duplicate()
		_input_as_id[i] = inputs[i]
	
	for i in range(size, sequence_length):
		output[i] = embedding.data[0].duplicate()
		_input_as_id[i] = 0
	
	return Matrix.new().fill_force(output).add_self(PE_cache.slice_row(0, sequence_length))

func forward_sentence(inputs:String, sequence_length:int = SEQUENCE_LENGTH):
	return forward(
		parse(inputs), sequence_length
	)

func backward(inputs:Matrix):
	return inputs.mul_t(embedding).softmax()

func output_to_sentence(output:Matrix):
	var highest = highest(output)
	var result:PackedStringArray = ids_to_words(highest)
	return result

func backward_sentence(inputs:Matrix):
	var size = inputs.row_size
	var output = backward(inputs)
	var highest = highest(output)
	var result:PackedStringArray = ids_to_words(highest)
	return result

#func learn_forward(error:Matrix):
#	var inputs:PackedInt64Array = _input_as_id
#	var learn:Matrix = Matrix.new()
#	learn.init(embedding.row_size, VECTOR_SIZE)
#	var error_rows:Array[PackedFloat64Array] = error.data
#	for i in range(inputs.size()):
#		learn.self_add_row(inputs[i], error_rows[i])
#	learn.mul_self_by_number(0.1/pow(VECTOR_SIZE, 2.0)/inputs.size())
##	print("learn ", learn)
#	embedding.min_self(learn)

func learn_forward(error:Matrix):
	var inputs:PackedInt64Array = _input_as_id
	var learn:Matrix = Matrix.new()
	learn.init(embedding.row_size, VECTOR_SIZE)
	var error_rows:Array[PackedFloat64Array] = error.data
	var learn_array:Array
	learn_array.resize(embedding.row_size)
	learn_array.fill(null)
	for i in range(inputs.size()):
		var id = inputs[i]
		if id == 0:
			continue
		if learn_array[id] == null:
			learn_array[id] = [error_rows[i].duplicate(), 1]
		else:
			learn_array[id][0] = Matrix.row_addition(learn_array[id][0], error_rows[i])
			learn_array[id][1] += 1
	
	for i in range(inputs.size()):
		var id = inputs[i]
		if learn_array[id] == null:
			continue
		var this_learn = Matrix.self_row_multiply_by_number(learn_array[id][0], 1.0/learn_array[id][1])
		learn.self_add_row(id, this_learn)
	learn.mul_self_by_number(_learning_rate)
#	print("learn ", learn)
	embedding.min_self(learn)
#	embedding.self_activation_normalization()
#	embedding.self_minmax_normalization()

func learn_backward(inputs:Matrix, error:Matrix)->Matrix:
	var learn:Matrix = error.transpose().mul(inputs)
#	print(learn)
	learn.mul_self_by_number(_learning_rate)
	embedding.min_self(learn)
#	embedding.self_activation_normalization()
#	embedding.self_minmax_normalization()
#	print(error.row_size, " ", error.col_size)
#	print(embedding.row_size, " ", embedding.col_size)
	return error.mul(embedding)

func highest(outputs:Matrix)->PackedInt64Array:
	var size:int = outputs.row_size
	var col_size:int = outputs.col_size
	var result:PackedInt64Array
	result.resize(size)
	
	for i in range(size):
		var col = outputs.data[i]
		var max:int = 0
		for j in range(col_size):
			if col[j] > col[max]:
				max = j
		result[i] = max
	return result

func parse(sentence:String):
	return words_to_ids(standard_split_word(sentence))

func rectify_backward(output:Matrix, expected:PackedInt64Array):
	var size:int = output.row_size
	var col_size:int = output.col_size
	expected.resize(SEQUENCE_LENGTH)
	for i in range(col_size, SEQUENCE_LENGTH):
		expected[i] = 0
	if size != expected.size():
		printerr("expected equal size of output and expected")
		print(size, " ", expected.size())
		return null
	var original_row:PackedFloat64Array
	original_row.resize(col_size)
	original_row.fill(0.0)
	var error:Matrix = output.duplicate()
#	print(output)
	for i in range(size):
		var index = expected[i]
		var row = original_row.duplicate()
		row[index] = 1.0
		error.self_min_row(i, row)
#	print(error)
	return error

func ids_to_words(ids:PackedInt64Array)->PackedStringArray:
	var size:int = ids.size()
	var word_position = word_dict.keys()
	var result:PackedStringArray
	result.resize(size)
	for i in range(size):
		result[i] = word_position[ids[i]]
	return result

func words_to_ids(words:PackedStringArray)->PackedInt64Array:
	var size:int = words.size()
	var ids:PackedInt64Array
	ids.resize(size)
	
	for i in range(size):
		var word = words[i]
		if word_dict.has(word):
			ids[i] = word_dict[word]
		else:
			ids[i] = -INF
			printerr("Unknown \"", word, "\"")
	
	return ids

func sentence_to_ids(sentence:String)->PackedInt64Array:
	return words_to_ids(
		sentence.split(" ", false)
	)

func standard_split_word(input:String)->PackedStringArray:
	input = input.to_lower()
	var splits = input.split(" ", false)
	var SPESIAL_CHAR:String = ".,:;"
	var words:PackedStringArray
	
	for split in splits:
		var word = split
		var s = word[-1]
		if s in SPESIAL_CHAR:
			word = word.substr(0, word.length()-1)
			words.append(word)
			words.append(s)
		else:
			words.append(word)
	
	return words

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
