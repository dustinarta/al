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
var data
var word_dict:Dictionary
var embedding:Matrix
var SEQUENCE_LENGTH:int
var VECTOR_SIZE:int
var PE_cache:Matrix

var _path:String

func _init():
	pass

func init(vector_size:int, sequence_length:int):
	word_dict = {}
	SEQUENCE_LENGTH = 0
	VECTOR_SIZE = vector_size
	embedding = Matrix.new().init(0, VECTOR_SIZE)
	PE_cache = Matrix.new()

func save(path:String):
	var data:Dictionary = {
		"sequence_length": SEQUENCE_LENGTH,
		"vector_size": VECTOR_SIZE,
		"word_dict": word_dict,
		"embedding": embedding.to_dict(),
		"pe_cache": PE_cache.to_dict()
	}
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

func forward(inputs:PackedInt64Array):
	var size:int = inputs.size()
	var output:Array[PackedFloat64Array]
	output.resize(size)
	
	for i in range(size):
		output[i] = embedding.data[inputs[i]].duplicate()
	
	return Matrix.new().fill_force(output)

func forward_sentence(inputs:String):
	return forward(
		parse(inputs)
	)

func backward(inputs:Matrix):
	return inputs.mul_t(embedding).softmax()

func backward_sentence(inputs:Matrix):
	var size = inputs.row_size
	var output = backward(inputs)
	var highest = highest(output)
	print(highest)
	var word_position = word_dict.keys()
	var result:PackedStringArray
	result.resize(size)
	for i in range(size):
		result[i] = word_position[highest[i]]
	return result

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
		new_matrix.shufle()
		print(new_matrix.row_size)
		print(embedding.row_size)
		embedding.self_append_rows(new_matrix.data)

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
