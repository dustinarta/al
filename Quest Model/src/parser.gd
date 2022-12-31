extends Reference

var _data:Dictionary

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

enum SENTENCE{
	STATEMENT,
	COMMAND
}

class Pharse:
	enum {
		SUBJECT,
		VERB,
		OBJECT,
		CONJUNCTION
	}
	var count:int
	var data:Array
	var type:int
	var child:Pharse
	
	func _init(type):
		self.type = type


func _init(data):
	if data == null:
		printerr("Data is empty")
	else:
		_data = data
	
func guess(sentence:String)->Array:
	var _return = []
	var words = sentence.split(" ")
	words = _remove_empty_string(words)
	var count = words.size()
	var temp
	var json_key = _data["key"]
#	first index as words
	_return.push_back(words)
	
#	second index as quest type and third index as quest index
	var key_id
	var quest_types = []
	quest_types.resize(count)
	var quest_index = []
	quest_index.resize(count)
	for i in range(count):
		key_id = _find_key(words[i])
		if key_id != -1:
			quest_types[i] = json_key[key_id][1]
			quest_index[i] = json_key[key_id][2]
	
	_return.push_back(quest_types)
	_return.push_back(quest_index)
	return _return

func _find_key(pharse:String)->int:
	var json_key = _data["key"]
	for i in range(json_key.size()):
		if json_key[i][0] == pharse:
			return i
	return -1

func _find_pharse(pharse:String)->Array:
	var _return = [null, null]
	var from_key = _find_key(pharse)
	if from_key == -1:
		for sub in _data["subject"]:
			if sub[0].has(pharse):
				_return[0] = 1
				_return[1] = sub[1]
				break
			printerr("Not even found " + pharse)
	else:
		_return[0] = 0
		_return[1] = from_key
	return _return

func is_vocal(s:String):
	return ["a", "i", "u", "e", "o"].has(s.to_lower())

func speech_position(speech:int, paragraph:Array)->Array:
	var position = []
	var length:int = paragraph.size()
	position.resize(length)
	position.fill(0)
	for i in range(length):
		if paragraph[i] & speech:
			position[i] = 1
	return position

func _remove_empty_string(array:Array)->Array:
	var new = []
	var count = array.size()
	new.resize(count)
	
	var offset = 0
	for id in range(count):
		var pos = array[id] as String
		if !pos.empty():
			new[offset] = pos
			offset += 1
	
	new.resize(offset)
	return new
