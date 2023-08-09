extends RefCounted
class_name AP

var Words:Dictionary
var Names:Dictionary
var Types:Dictionary
var Types_count:int
var Types_d:Dictionary
var Types_s:PackedStringArray

func _init():
	pass

func init():
	pass

func load(path:String):
	var f = FileAccess.open(path, FileAccess.READ)
	var data:Dictionary = JSON.parse_string(
		f.get_as_text()
	)
	Words = data["words"]
	setup_words()
	Names = data["names"]
	Types = data["types"]
	setup_types()
	f.close()

func save(path:String):
	var f = FileAccess.open(path, FileAccess.WRITE)
	var data = {
		"words" : Words,
		"names" : Names,
		"types" : Types
	}
	f.store_string(
		JSON.stringify(data, "\t", false, true)
	)
	f.close()

func setup_words():
	for word_data in Words.values():
		word_data["matrix"] = Matrix.new().load_from_string(word_data["matrix"])

func setup_types():
	Types_count = Types.size()
	Types_s = Types.keys()
	for i in range(Types_count):
		Types_d[Types_s[i]] = i

func set_name(names:PackedStringArray):
	var size = names.size()
	var i = 0
	var nameblock = Names
	while i < size:
		var name = names[i]
		if Names.has(name):
			nameblock = Names[name]
		else:
			var frontname = name
			var thisname = {}
			var nowname = thisname
			for j in range(i+1, names.size()):
				name = names[j]
				nowname[name] = {}
				nowname = nowname[name]
			nameblock[frontname] = thisname
			break
		i += 1

func set_name_auto(words:PackedStringArray, types:PackedInt64Array, index:int):
	var size = words.size()
	var i = index
	var nameblock = Names
	var NP = Types_d["NP"]
	while i < size:
		var name = words[i]
		if types[i] != NP:
			break
		if nameblock.has(name):
			nameblock = nameblock[name]
		else:
			var frontname = name
			var thisname = {}
			var nowname = thisname
			i += 1
			while i < size:
				if types[i] != NP:
					break
				name = words[i]
				nowname[name] = {}
				nowname = nowname[name]
				i += 1
			nameblock[frontname] = thisname
			break
		i += 1
	return i

#func is_name

func set_word(word:String, word_type:int):
	if Words.has(word):
		var row = Words[word]["matrix"].data[0]
		if highest(row) == word_type:
			return
	else:
		var matrix:Matrix = Matrix.new().init(1, Types_count, -1)
		matrix.data[0][word_type] = 1
		var data:Dictionary = {
			"b" : {},
			"a" : {},
			"matrix" : matrix
		}
		Words[word] = data

func set_word_with_string(word:String, word_type_s:String):
	var word_type:int = Types_d[word_type_s]
	set_word(word, word_type)

func learn(word_s, type_s):
	var words:PackedStringArray = parse_word(word_s)
	var types:PackedInt64Array = parse_type(type_s)
	
	if words.size() != types.size():
		printerr("Expected same size!")
		return null
	
	var size:int = words.size()
	var i:int = 0
	var NP = Types_d["NP"]
	while i < size:
		if types[i] == NP:
			i = set_name_auto(words, types, i)
			continue
		set_word(words[i], types[i])
		i += 1
	

func read(sentence:String):
	var words = parse_word(sentence)
	var size = words.size()
	var result:PackedStringArray
	result.resize(words.size())
	
	for w in range(size):
		var word = words[w]
		if Words.has(word):
			var self_matrix:Matrix = Words[word]["matrix"]
			var row = self_matrix.data[0]
			result[w] = Types_s[ highest(row) ]
#			if w > 1:
#			
			
		else:
			result[w] = "UW"
	return result

func parse_word(sentence:String):
	sentence = sentence.to_lower()
	var split:PackedStringArray = sentence.split(" ")
	var result:PackedStringArray
	for word in split:
		var w = word[-1]
		if w == ",":
			result.append(",")
			word = word.substr(0, -2)
		result.append(word)
	return result

func parse_type(sentence:String):
	var split:PackedStringArray = sentence.split(" ")
	var result:PackedInt64Array
	for type in split:
		if Types.has(type):
			result.append( Types_d[type] )
		else:
			printerr("Undefined type ", type)
			return null
	return result

func highest(numbers:PackedFloat64Array):
	var highest:int = 0
	for i in range(numbers.size()):
		if numbers[i] > numbers[highest]:
			highest = i
	return highest

class Phrase:
	var type:En.PHRASE_TYPE
