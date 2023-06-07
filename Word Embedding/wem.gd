@tool
extends RefCounted
class_name WEM

var _alldata:Dictionary = {}
var keys:Dictionary
var weights:Array

var path = "res://Word Embedding/model.json"

func _init():
	self.load(self.path)

func load(path:String = self.path):
	_alldata = JSON.parse_string(FileAccess.open(path, FileAccess.READ).get_as_text())
	keys = _alldata["keys"]
	weights = _alldata["weights"]

func save(path:String = self.path):
	FileAccess.open(path, FileAccess.WRITE).store_string(JSON.stringify(_alldata, "\t"))

func push(sentence:String):
	var words:PackedStringArray = sentence.split(" ")
	
	for k in words:
		if not keys.has(k):
			keys[k] = keys.size()
			
			
			
			
