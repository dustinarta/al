extends RefCounted
class_name Transformer

var VECTOR_SIZE:int
var Query
var Key
var Value
var Words_id
var Words_vector

static func create(path:String, vector_size:int, words:Dictionary):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var word_size:int = words.size()
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
	var words_id:Dictionary = words.duplicate()
	var words_vector:Array
	words_vector.resize(word_size)
	for word in range(word_size):
		words_vector[word] = array.duplicate()
	
	var data = {
		"q" : matrix_data,
		"k" : matrix_data,
		"v" : matrix_data,
		"words_id" : words_id,
		"words_vector" : words_vector
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
	Words_id = data["words_id"]
	Words_vector = data["words_vector"]
	VECTOR_SIZE = Words_vector[0].size()

func encode(inputs):
	pass

func words_to_vectors(input:String):
	var split = input.split(" ", false)
	var result:Array[PackedFloat64Array]
	var matrix:Matrix = Matrix.new()
	for s in split:
		result.append( Words_vector[Words_id[s]] as PackedFloat64Array )
	
	print(split)
	matrix.fill_force(result)
	return matrix.add( positional_encoding(split.size(), VECTOR_SIZE) )

func positional_encoding(length:int, dimension:int):
	var matrix:Matrix = Matrix.new()
	var results:Array[PackedFloat64Array]
	results.resize(length)
	var pos
	for i in range(length):
		pos = i
		var result:PackedFloat64Array
		result.resize(dimension)
		for d in range(dimension/2):
			result[d*2] = sin( pos / pow(10000, (d/float(dimension))) )
			result[d*2+1] = cos( pos / pow(10000, (d/float(dimension))) )
		results[i] = result
	return matrix.fill_force(results)
