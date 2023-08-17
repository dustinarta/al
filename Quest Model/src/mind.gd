extends Resource
class_name Mind

var _data :Dictionary
var Parser
var Venn

enum SPEECH {
	NOUN = 1,
	PRONOUN = 2,
	VERB = 4,
	ADJECTIVE = 8,
	ADVERB = 16,
	CONJUNCTION = 32,
	PREPOSITION = 64,
	ARTICLE = 128,
	INTERJECTION = 256
}

func _init(data = null):
	if typeof(data) == TYPE_DICTIONARY:
		_data = data
	else:
		print("Empty data")
	Parser = load("res://src/parser.gd").new(_data)
	Venn = load("res://src/venn.gd").new()

func talk(paragraph:String):
	paragraph = paragraph.to_lower()
	return Parser.guess(paragraph)
#	_clause()

func _clause(paragraph:Array):
	var _s = paragraph[0]
	var _d = paragraph[1]
	var _t = paragraph[2]
	
	var idx: = 0
	var _limit = _s.size()
	
	print(Parser.speech_position(SPEECH.VERB, paragraph[2]))
	
#	while (idx < _limit):
#		pass

func save(path)->void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(_data, "\t", false))
	
#func find_description(req:Array):
#	var reqlen = req.size()
#
#	var description = _data["information"]["description"]
#	for des in description:
#
#		if reqlen < des.size():
#
#

func find_subject(name:String)->int:
	var subject = _data["subject"]
	
	for sub in subject:
		if sub[0].has(name):
			return sub[1]
	
	return -1
