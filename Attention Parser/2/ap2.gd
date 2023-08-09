extends RefCounted
class_name AP2

var Words:Dictionary
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
	Types = data["types"]
	setup_types()
	f.close()

func save(path:String):
	var f = FileAccess.open(path, FileAccess.WRITE)
	var data = {
		"words" : Words,
		"types" : Types
	}
	f.store_string(
		JSON.stringify(data, "\t", false, true)
	)
	f.close()

func setup_types():
	Types_count = Types.size()
	Types_s = Types.keys()
	for i in range(Types_count):
		Types_d[Types_s[i]] = i

func set_word(word:String, word_type:int):
	if Words.has(word):
		print("word ", word)
	else:
		Words[word] = {
			"#" : Types_s[word_type]
		}

func set_word_branch_name(words:PackedStringArray, types:PackedStringArray, index:int):
	var word_block = Words
	var i = index
	while i < words.size():
		if types[i] != "NP":
			break
		var word = words[i]
		if word_block.has(word):
			word_block = word_block[word]
		else:
			word_block[word] = {}
			word_block = word_block[word]
		i += 1
	if word_block.has("#"):
		if word_block["#"] != "NP":
			printerr("unmatched ", word_block)
			return i
	word_block["#"] = "NP"
	return i

func get_name(words:PackedStringArray, index:int, result:PackedStringArray):
	var size = words.size()
	var j:int = 1
	var i:int = index
	var word_block:Dictionary = Words[words[i]]
	i += 1
	if i+1 == size:
		if word_block.has("#"):
			if word_block["#"] == "NP":
				result[i] = "NP"
				return i
		else:
			printerr("uncomplete")
	while i+1 < size:
		var word:String = words[i]
		if word_block.has(word):
			word_block = word_block[word]
			j += 1
			i += 1
			continue
		if word_block.has("#"):
			if word_block["#"] == "NP":
				for k in range(index, index+j):
					result[k] = "NP"
				return i
		break
	return index

func read(sentence:String):
	var words:PackedStringArray = parse_word(sentence)
	var size = words.size()
	var result:PackedStringArray
	result.resize(size)
	var i:int = 0
	while i < size:
		var word = words[i]
		var j = get_name(words, i, result)
		if j > i:
			i = j
			continue
		if Words.has(word):
			result[i] = Words[word]["#"]
		i += 1
	return result

func learn(word_s:String, type_s:String):
	var words:PackedStringArray = parse_word(word_s)
	var types:PackedStringArray = type_s.split(" ", false)
	var size = words.size()
	var i:int = 0
	while i < size:
		var word = words[i]
		if types[i] == "NP":
			i = set_word_branch_name(words, types, i)
			continue
		if Words.has(word):
			var word_data = Words[word]
			if word_data.has("#"):
				print("already exist ", word)
		else:
			Words[word] = {
				"#" : types[i]
			}
		i += 1
	

func is_spesial_character(sc:String):
	return sc in ",.:;'\""

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
