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
	embedding_input.init([size, vec_count], [0, NN3.ACTIVATION.SIGMOID], true)
	encoder.init(size)
	decoder.init(size)
	embedding_output.init([size, vec_count], [0, NN3.ACTIVATION.SIGMOID], true)
	vec2word.init([vec_count, size], [0, NN3.ACTIVATION.SIGMOID], true)

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
	embedding_output.load_from_dict(data["embedding_output"])
	vec2word.load_from_dict(data["vec2word"])
	encoder.load_from_dict(data["encoder"])
	decoder.load_from_dict(data["decoder"])
	


