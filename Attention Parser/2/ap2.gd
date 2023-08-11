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

func get_branch(words:PackedStringArray, index:int, result:PackedStringArray)->bool:
	var size = words.size()
	if index+1 == size:
		return false
	var j:int = 1
	var i:int = index
	var word_block:Dictionary = Words[words[i]]
	if word_block.has(">W"):
		word_block = word_block[">W"]
#		print("here")
		while i+1 < size:
			var next_word = words[i+1]
#			print("next_word ", next_word)
			if word_block.has(next_word):
				word_block = word_block[next_word]
			else:
				if word_block.has("#"):
					result[index] = word_block["#"]
					return true
			i += 1
	return false

func read(sentence:String):
	var words:PackedStringArray = parse_word(sentence)
	var size = words.size()
	var result:PackedStringArray
	result.resize(size)
	var i:int = 0
	while i < size:
		var word = words[i]
#		var j = get_name(words, i, result)
		if i+1 != size:
			var j:int = i
			var word_block:Dictionary = Words[words[j]]
			if word_block.has(">W"):
				word_block = word_block[">W"]
		#		print("here")
				while j+1 < size:
					var next_word = words[j+1]
		#			print("next_word ", next_word)
					if word_block.has(next_word):
						word_block = word_block[next_word]
					else:
						if word_block.has("#"):
							result[i] = word_block["#"]
						break
					j += 1
				if j != i:
					i += 1
					continue
			j = i + 1
			if word_block.has(">T"):
				word_block = word_block[">T"]
				var next_block = Words[words[j]]
				if next_block.has("#"):
					var next_type = next_block["#"]
					if word_block.has(next_type):
						result[i] = word_block[next_type]
						i += 1
						continue
		if Words.has(word):
			result[i] = Words[word]["#"]
		i += 1
	return result

func learn_base(word_s:String, type_s:String):
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

func is_aplhabet(letter:String):
	return letter in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

func is_number(number:String):
	return number in "0123456789"

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

func parse_phrase(words:PackedStringArray, types:PackedStringArray):
	var size:int = words.size()
	var packedphrase = PackedPhrase.new()
	var i = 0
	while i < size:
		var type:String = types[i]
		var type1:String = type[0]
		var type2:String = type[1]
		if type1 == "N":
			var phrase:Phrase = Phrase.parse_noun(words, types, i, size)
			if phrase == null:
				printerr("parsing error! at index ", i)
				return null
			i += phrase.size
			packedphrase.append(
				phrase
			)
		elif type1 == "J":
			var phrase:Phrase = Phrase.parse_adjective(words, types, i, size)
			if phrase == null:
				printerr("parsing error! at index ", i)
				return null
			i += phrase.size
			packedphrase.append(
				phrase
			)
		elif type1 == "V":
			var phrase:Phrase = Phrase.parse_verb(words, types, i, size)
			if phrase == null:
				printerr("parsing error! at index ", i)
				return null
			i += phrase.size
			packedphrase.append(
				phrase
			)
		print(i)
	return packedphrase

class PackedPhrase:
	var phrases:Array[Phrase]
	
	func _init():
		pass
	
	func append(phrase:Phrase):
		phrases.append(phrase)
	
	func _to_string():
		return str(phrases)
	

class Phrase:
	var phrasetype:En.PHRASE_TYPE
	var words:PackedStringArray
	var types:PackedStringArray
	var size:int
	
	func _init():
		size = 0
	
	func append(word:String, type:String):
		words.append(word)
		types.append(type)
		size += 1
	
	func steal(phrase:Phrase):
		words.append_array(phrase.words)
		types.append_array(phrase.types)
		size += phrase.size
	
	func _to_string():
		var s:String = "["
		s += " ".join(words) + ", "
		s += " ".join(types) + "]"
		return s
	
	static func parse_noun(words:PackedStringArray, types:PackedStringArray, index:int, limit:int)->Phrase:
		var phrase:Phrase = Phrase.new()
		var i:int = index
		var type = types[i]
		var type1 = type[0]
		var type2 = type[1]
		if type1 != "N":
			return null
		if type2 == "P":
			while i < limit:
				type = types[i]
				if type == "NP":
					phrase.append(words[i], "NP")
				else:
					break
				i += 1
			return phrase
		elif type2 == "C":
			while i < limit:
				type = types[i]
				if type == "NC":
					phrase.append(words[i], "NC")
				else:
					break
				i += 1
			return phrase
		else:
			printerr("Unrecognized ", type)
		return null
	
	static func parse_verb(words:PackedStringArray, types:PackedStringArray, index:int, limit:int)->Phrase:
		var phrase:Phrase = Phrase.new()
		var i:int = index
		var type = types[i]
		var type1 = type[0]
		var type2 = type[1]
		if type1 != "V":
			return null
		phrase.append(words[index], type)
		if type2 == "A":
			i += 1
			if i >= limit:
				return phrase
			var next_type = types[i]
			var next_type1 = next_type[0]
			var next_type2 = next_type[1]
			
			if next_type1 == "V":
				if next_type2 == "_":
					phrase.append(words[i], "V_")
				elif next_type2 == "A":
					phrase.append(words[i], "VA")
				return phrase
		elif type2 == "M":
			i += 1
			if i >= limit:
				return phrase
			var next_type = types[i]
			var next_type1 = next_type[0]
			var next_type2 = next_type[1]
			
			if next_type1 == "V":
				if next_type2 == "A":
					phrase.append(words[i], "VA")
				return phrase
		elif type2 == "_":
			return phrase
		return null
	
	static func parse_adjective(words:PackedStringArray, types:PackedStringArray, index:int, limit:int)->Phrase:
		var phrase:Phrase = Phrase.new()
		var i:int = index
		var type = types[i]
		var type1 = type[0]
		var type2 = type[1]
		if type1 != "J":
			return null
		phrase.append(words[i], type)
		if type2 == "A":
			i += 1
			if i >= limit:
				return phrase
			var next_type = types[i]
			var next_type1 = next_type[0]
			var next_type2 = next_type[1]
			if next_type1 == "N":
				phrase.steal(
					Phrase.parse_noun(words, types, i, limit)
				)
				return phrase
		return null
