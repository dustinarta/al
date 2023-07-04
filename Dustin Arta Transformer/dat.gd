@tool
extends Node

const SPESIAL_CHAR:PackedStringArray = [
	",", ".", ":", ";", "\""
]

const BASIC_CHAR:Dictionary = {
	# 0 - 19
	"<SOS>" : 0, "<PAD>" : 1, "<EOS>" : 2,
	# 20 - 39 : front of string
	",>" : 20, ".>" : 21, ":>" : 22, ";>" : 23,  "\">" : 24,
	# 40 - 59 : middle of string
	"<,>" : 40, "<.>" : 41, "<:>" : 42, "<;>" : 43, "<\">" : 44,
	# 60 - 79 : back of string
	"<," : 60, "<." : 61, "<:" : 62, "<;" : 63, "<\"" : 64,
}

var data:Dictionary

var memories:Array
var words:Dictionary
var words_keys:Dictionary

var paths = {
	"words" : "res://Dustin Arta Transformer/words.json"
}

func _init():
	init()

func init():
	paths = {
	"words" : "res://Dustin Arta Transformer/words.json"
	}
	self.load()

func init_words(new_size:int):
	words["size"] = new_size
	words["keys"] = {}
	words["vectors"] = []
	var array:PackedFloat64Array
	array.resize(new_size)
	array.fill(0.5)
	words["q"] = array.duplicate()
	words["k"] = array.duplicate()
	words["v"] = array.duplicate()

func add_words(packedstring:PackedStringArray):
	var word_size:int = words["size"]
	var keys:Dictionary = words["keys"]
	var vectors:Array = words["vectors"]
	
	for s in packedstring:
		if keys.has(s):
			continue
		
		var index = keys.size()
		keys[s] = index
		var array:PackedFloat64Array
		array.resize(word_size)
		array.fill(0.5)
		vectors.append(array.duplicate())

func add_words_with_sentence(sentence:String):
	var result:PackedStringArray = sentence_standard_split(sentence)
	add_words(result)

func sentence_standard_split(sentence:String)->PackedStringArray:
	var packedsentence = sentence.split(" ")
	var sentence_count = packedsentence.size()
	
	var result:PackedStringArray
	var char:String
	char = word[-1]
	if SPESIAL_CHAR.has(char):
		result.append( words_keys[ "<"+char ] )
		word = word.left(word.length()-1)
	for i in range(sentence_count):
		var s = packedsentence[i]
		if SPESIAL_CHAR.has(s[-1]):
			result.append(s[-1] + " ")
			result.append(s.left(s.length()-1))
		else:
			result.append(s)
	return result

func sentence_to_id(sentence:String):
	var packedsentence = sentence.split(" ")
	var sentence_count = packedsentence.size()
	var result:PackedInt64Array
	
	for i in range(sentence_count):
		var s = packedsentence[i]
		if SPESIAL_CHAR.has(s[-1]):
			result.append(s[-1] + " ")
			result.append( words["keys"] [ s.left(s.length()-1) ] )
		else:
			result.append( words["keys"] [ s ] )
	
	return result

func push(input:String):
	pass

func encode(input:PackedInt64Array):
	var mat1 = Matrix.new().init(1, 512).fill(
		[ words["q"] ]
	)
	var mat2 = Matrix.new().init(1, 512).fill(
		[ words["k"] ]
	)
	print(mat1.mul(mat2.transpose()))

func retrive_word(word:String):
	var result:PackedInt64Array
	var char:String
	char = word[-1]
	if SPESIAL_CHAR.has(char):
		result.append( words_keys[ "<"+char ] )
		word = word.left(word.length()-1)
	
	return result

func find_id_in_basic_char(char:String, pos:int):
	var this:int = SPESIAL_CHAR.find(char)
	if this == -1:
		return -1
	return this + pos * 20 + 20

func load(paths:Dictionary = self.paths):
	# load words
	words = JSON.parse_string( FileAccess.open(
		paths["words"], FileAccess.READ
		).get_as_text() 
	)

func save(paths:Dictionary = self.paths):
	# save words
	FileAccess.open(paths["words"], FileAccess.WRITE).store_string(
		JSON.stringify(words, "\t", false)
	)
