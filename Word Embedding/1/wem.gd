@tool
extends RefCounted
class_name WEM

var _alldata:Dictionary = {}
var keys:Dictionary
var weights:Array
var cell_count:int

var path = "res://Word Embedding/model.json"

func _init():
	self.load(self.path)

func load(path:String = self.path):
	_alldata = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
	keys = _alldata["keys"]
	weights = _alldata["weights"]
	cell_count = _alldata["cell_count"]

func save(path:String = self.path):
	FileAccess.open(path, FileAccess.WRITE).store_string(JSON.stringify(_alldata, "\t"))

func push(sentence:String):
	var words:PackedStringArray = sentence.split(" ")
	var size:int = words.size()
	var key_ids:PackedInt64Array
	key_ids.resize(size+1)
	
	for k in range(size):
		var key = words[k]
		if not keys.has(key):
			printerr("undefined ", k)
			return null
		else:
			key_ids[k] = keys[key]
	key_ids[size] = 0

func learn(input:String, expectedoutput:String):
	var inputs:PackedStringArray = input.split(" ")
	var outputs:PackedStringArray = expectedoutput.split(" ")
	
	for k in inputs:
		if not keys.has(k):
			keys[k] = keys.size()
			var weight:PackedFloat64Array
			weight.resize(cell_count)
			for w in range(cell_count):
				weight[w] = randf_range(-1, 1)
			weights.append(weight)
	
	for k in outputs:
		if not keys.has(k):
			keys[k] = keys.size()
			var weight:PackedFloat64Array
			weight.resize(cell_count)
			for w in range(cell_count):
				weight[w] = randf_range(-1, 1)
			weights.append(weight)
	
