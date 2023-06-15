@tool
extends RefCounted
class_name SEM

const SPESIAL_CHAR:PackedStringArray =[".", ",", ":", ";", "!", "?"]

var embedding_input:NN3
var embedding_output:NN3
var vec2word:NN3
var vec_count:int
var encoder:MultiLSTM
var decoder:MultiLSTM

var keys:Dictionary
var path:String

func _init():
	embedding_input = NN3.new()
	encoder = MultiLSTM.new()
	decoder = MultiLSTM.new()
	embedding_output = NN3.new()
	vec2word = NN3.new()

func create(paragraph:PackedStringArray, vec_count:int):
	_init_keys()
	read_word(paragraph)
	self.vec_count = vec_count
	var size = keys.size()
	embedding_input.init([size, vec_count], [NN3.ACTIVATION.NONE], true)
	encoder.init(vec_count)
	decoder.init(vec_count)
	embedding_output.init([size, vec_count], [NN3.ACTIVATION.NONE], true)
	vec2word.init([vec_count, size], [NN3.ACTIVATION.SOFTMAX], true)

func _init_keys():
	keys["\\sos"] = 0
	keys["\\eos"] = 1
	
	for s in range(2, SPESIAL_CHAR.size()+2):
		keys[SPESIAL_CHAR[s-2]] = s

func read_word(paragraph:PackedStringArray):
	for split in paragraph:
		var splits:PackedStringArray = split.split(" ")
		
		for s in splits:
			if SPESIAL_CHAR.has(s[-1]):
				s = s.left(s.length()-1)
				print(s)
			if not keys.has(s):
				keys[s] = keys.size()

func push(input:String):
	var inputs_id = sentence_to_id(input)
	var vector_count
	
	var vectors:Array = wordid_many_to_vector(inputs_id)
	vector_count = vectors.size()
	var results
#	for en in range(vector_count):
#		print("ini disini")
	results = encoder.forward( row_col( vectors ) )
	decoder.move_memory(encoder)
	vectors = embedding_output.forward_by_id([0])
	results = decoder.forward_col(vectors)
	results = row_col(results)
	results = row_col(results[-1])
	results = vec2word.forward(results[-1])
	print(results)
	var highest = highest(results)
	print(keys.keys()[highest])

func wordid_to_vector(id:int):
	return embedding_input.forward_by_id([id])

func wordid_many_to_vector(ids:PackedInt64Array)->Array[PackedFloat64Array]:
	var size = ids.size()
	var vectors:Array[PackedFloat64Array]
	vectors.resize(size)
	for i in range(size):
		vectors[i] = embedding_input.forward_by_id([ids[i]])[-1]
	return vectors

func train(input:String, output:String):
	var inputs_id = sentence_to_id(input)
	var outputs_id = sentence_to_id(output)
	


func row_col(data:Array):
	var row_len = data.size()
	var col_len = data[0].size()
	
	for i in range(1, row_len):
		if data[i].size() != col_len:
			printerr("invalid count!")
	var new_data:Array = []
	new_data.resize(col_len)
	for r in range(col_len):
		var new_column:Array = []
		new_column.resize(row_len)
		for c in range(row_len):
			new_column[c] = data[c][r]
		new_data[r] = new_column
	return new_data

func string_to_id(packedstring:PackedStringArray):
	var size:int = packedstring.size()
	var packedid:PackedInt64Array
	packedid.resize(size)
	
	for i in range(size):
		packedid[i] = keys[packedstring[i]]
	
	return packedid

func split_sentence(sentence:String):
	var split:PackedStringArray = []
	var splits:PackedStringArray = sentence.split(" ")
	
	for s in splits:
		if SPESIAL_CHAR.has(s[-1]):
			s = s.left(s.length()-1)
		split.append(s)
	return split

func sentence_to_id(sentence:String):
	var packedid:PackedInt64Array = []
	var splits:PackedStringArray = sentence.split(" ")
	
	for s in splits:
		var char:String = ""
		if SPESIAL_CHAR.has(s[-1]):
			char = s[-1]
			s = s.left(s.length()-1)
		packedid.append(keys[s])
		if char:
			packedid.append(keys[char])
	return packedid

func highest(packedfloat:PackedFloat64Array):
	var at:int = 0
	
	for i in range(packedfloat.size()):
		if packedfloat[i] > packedfloat[at]:
			at = i
	return at

func _to_dictionary():
	var data:Dictionary
	data["vec_count"] = vec_count
	data["keys"] = keys
	data["embedding_input"] = embedding_input._to_dictionary()
	data["embedding_output"] = embedding_output._to_dictionary()
	data["vec2word"] = vec2word._to_dictionary()
	data["encoder"] = encoder._to_dictionary()
	data["decoder"] = decoder._to_dictionary()
	return data

func save(path:String = self.path):
	FileAccess.open(path, FileAccess.WRITE).store_string(
		JSON.stringify(_to_dictionary(), "\t")
	)

func load(path:String = self.path):
	var data:Dictionary = JSON.parse_string(
		FileAccess.open(path, FileAccess.READ).get_as_text()
	)
	
	vec_count = data["vec_count"]
	keys = data["keys"]
	embedding_input.load_from_dict(data["embedding_input"])
#	print("loading")
	embedding_output.load_from_dict(data["embedding_output"])
#	print("loading")
	vec2word.load_from_dict(data["vec2word"])
#	print("loading")
	encoder.load_from_dict(data["encoder"])
#	print("loading")
	decoder.load_from_dict(data["decoder"])
#	print("loading")
