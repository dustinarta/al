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
var VECTOR_SIZE:int
var PE_cache:Matrix

var _path:String

func _init():
	pass

func init(vector_size:int):
	VECTOR_SIZE = vector_size
	embedding = Matrix.new().init(0, VECTOR_SIZE)

func forward():
	pass

func backward():
	pass

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
		embedding.self_append_rows(new_matrix.data)

func standard_split_word(input:String):
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
