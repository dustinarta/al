extends RefCounted
class_name AP2

const SYMBOLS = ",.:;'\""

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

func read_s(sentence:String):
	var words:PackedStringArray = parse_word(sentence)
	return read(words)

func read(words:PackedStringArray):
	var size = words.size()
	var result:PackedStringArray
	result.resize(size)
	var i:int = 0
	while i < size:
		var word = words[i]
		if !Words.has(word):
			result[i] = "UW"
			i += 1
			continue
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
#				else:
#					result[i] = Words[words[j]]["#"]
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
		else:
			result[i] = "UW"
		i += 1
	return result

func learn_base_s(word_s:String, type_s:String):
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

func learn_base(words:PackedStringArray, types:PackedStringArray):
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
	return sc in SYMBOLS

func is_aplhabet(letter:String):
	return letter in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

func is_number(number:String):
	return number in "0123456789"

func parse_word(sentence:String):
	sentence = sentence.to_lower()
	var split:PackedStringArray = sentence.split(" ", false)
	var result:PackedStringArray
	for word in split:
		var w = word[-1]
		if w == ",":
			word = word.substr(0, word.length()-1)
		else:
			w = ""
		result.append(word)
		if w:
			result.append(w)
	return result

func parse_type(sentence:String):
	var split:PackedStringArray = sentence.split(" ", false)
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

func parse_phrase_s(sentence:String):
	var words:PackedStringArray = parse_word(sentence)
	var types:PackedStringArray = read(words)
	return parse_phrase(words, types)

func parse_phrase(words:PackedStringArray, types:PackedStringArray):
	var size:int = words.size()
	var packedphrase = PackedPhrase.new()
	var i = 0
	while i < size:
		var type:String = types[i]
		var type1:String = type[0]
		var type2:String = type[1]
		#Noun
		if type1 == "N":
			var phrase:Phrase = Phrase.parse_noun(words, types, i, size)
			if phrase == null:
				printerr("parsing noun error! at index ", i)
				return null
			i += phrase.size
			packedphrase.append(
				phrase
			)
		#Pronoun
		elif type1 == "P":
			var phrase:Phrase = Phrase.parse_pronoun(words, types, i, size)
			if phrase == null:
				printerr("parsing pronoun error! at index ", i)
				return null
			i += phrase.size
			packedphrase.append(
				phrase
			)
		#Adjective
		elif type1 == "J":
			var phrase:Phrase = Phrase.parse_adjective(words, types, i, size)
			if phrase == null:
				printerr("parsing adjective error! at index ", i)
				return null
			i += phrase.size
			packedphrase.append(
				phrase
			)
		#Adverb
		elif type1 == "B":
			var phrase:Phrase = Phrase.parse_adverb(words, types, i, size)
			if phrase == null:
				printerr("parsing adverb error! at index ", i)
				return null
			i += phrase.size
			packedphrase.append(
				phrase
			)
		#Verb
		elif type1 == "V":
			var phrase:Phrase = Phrase.parse_verb(words, types, i, size)
			if phrase == null:
				printerr("parsing verb error! at index ", i)
				return null
			i += phrase.size
			packedphrase.append(
				phrase
			)
		#Preposition
		elif type1 == "R":
			var phrase:Phrase = Phrase.parse_preposition(words, types, i, size)
			if phrase == null:
				printerr("parsing preposition error! at index ", i)
				return null
			i += phrase.size
			packedphrase.append(
				phrase
			)
		#Conjunction
		elif type1 == "C":
			var phrase:Phrase = Phrase.parse_conjunction(words, types, i, size)
			if phrase == null:
				printerr("parsing conjunction error! at index ", i)
				return null
			i += phrase.size
			packedphrase.append(
				phrase
			)
		elif is_spesial_character(type1):
			var phrase:Phrase = Phrase.parse_symbol(words, types, i, size)
			if phrase == null:
				printerr("parsing symbol error! at index ", i)
				return null
			i += phrase.size
			packedphrase.append(
				phrase
			)
		else:
			var phrase:Phrase = Phrase.new()
			phrase.phrasetype == En.PHRASE_TYPE.Undefined
			phrase.words = [words[i]]
			phrase.types = ["UW"]
			packedphrase.append(
				phrase
			)
			i += 1
#		print(i)
	return packedphrase

func guess_phrase(packedphrase:PackedPhrase):
	var phrases:Array[Phrase] = packedphrase.phrases
	var before:Phrase = null
	var now:Phrase = phrases[0]
	var after:Phrase
	var limit = packedphrase.size()
	
	var result:Array
	
	var i:int = -1
	while i+1 < limit:
		i += 1
		now = phrases[i]
		if now.phrasetype == En.PHRASE_TYPE.Conjunctive:
			before = null
			after = null
			if i-1 >= 0:
				before = phrases[i-1]
			if i+1 < limit:
				after = phrases[i+1]
			if after != null and before != null:
				if ((before.phrasetype == En.PHRASE_TYPE.Noun 
					or 
					before.phrasetype == En.PHRASE_TYPE.Pronoun
					or 
					before.phrasetype == En.PHRASE_TYPE.Adjective)
					and 
					(after.phrasetype == En.PHRASE_TYPE.Noun 
					or 
					after.phrasetype == En.PHRASE_TYPE.Pronoun
					or 
					before.phrasetype == En.PHRASE_TYPE.Adjective)):
					var before2
					var after2
					if i-2 >= 0:
						before2 = phrases[i-2]
					if i+2 < limit:
						after2 = phrases[i+2]
					if after2 != null and before2 != null:
						if (before2.phrasetype == En.PHRASE_TYPE.Verb
							or
							before2.phrasetype == En.PHRASE_TYPE.Prepositional):
							if after2.phrasetype == En.PHRASE_TYPE.Verb:
								result.append(
									[i, now.words[0], "CS"]
								)
								continue
					result.append(
						[i, now.words[0], "CE"]
					)
				elif (before.phrasetype == En.PHRASE_TYPE.Symbol 
					and 
					(after.phrasetype == En.PHRASE_TYPE.Noun 
					or 
					after.phrasetype == En.PHRASE_TYPE.Pronoun)):
					result.append(
						[i, now.words[0], "CE"]
					)
				elif after.phrasetype == En.PHRASE_TYPE.Verb:
					result.append(
						[i, now.words[0], "CS"]
					)
		elif now.phrasetype == En.PHRASE_TYPE.Undefined:
			before = null
			after = null
			if i-1 >= 0:
				before = phrases[i-1]
			if i+1 < limit:
				after = phrases[i+1]
			
			if after != null and before != null:
				if ( (before.phrasetype == En.PHRASE_TYPE.Noun 
					or 
					before.phrasetype == En.PHRASE_TYPE.Pronoun) 
					and 
					after.phrasetype == En.PHRASE_TYPE.Verb ):
					result.append(
						[i, now.words[0], "B_"]
					)
			elif after != null:
				if after.phrasetype == En.PHRASE_TYPE.Verb:
					result.append(
						[i, now.words[0], "N_"]
					)
		elif now.phrasetype == En.PHRASE_TYPE.Symbol:
			before = null
			after = null
			if i-1 >= 0:
				before = phrases[i-1]
			if i+1 < limit:
				after = phrases[i+1]
			if now.types[0] == ",_":
				if before != null and after != null:
					if ((before.phrasetype == En.PHRASE_TYPE.Noun 
						or 
						before.phrasetype == En.PHRASE_TYPE.Pronoun)
						and 
						(after.phrasetype == En.PHRASE_TYPE.Noun 
						or 
						after.phrasetype == En.PHRASE_TYPE.Pronoun)):
						var after2
						if i+2 < limit:
							after2 = phrases[i+2]
						if after2 != null:
							if after2.phrasetype == En.PHRASE_TYPE.Verb:
								result.append(
									[i, now.words[0], ",S"]
								)
							elif after2.phrasetype == En.PHRASE_TYPE.Symbol:
								if after2.words[0] == ",":
									result.append(
										[i, now.words[0], ",E"]
									)
					elif ((before.phrasetype == En.PHRASE_TYPE.Noun 
						or 
						before.phrasetype == En.PHRASE_TYPE.Pronoun)
						and 
						(after.phrasetype == En.PHRASE_TYPE.Conjunctive)):
							result.append(
								[i, now.words[0], ",E"]
							)
		elif now.phrasetype == En.PHRASE_TYPE.Prepositional:
			before = null
			after = null
			if i-1 >= 0:
				before = phrases[i-1]
			if i+1 < limit:
				after = phrases[i+1]
			if after != null:
				if now.words[0] == "to" and after.phrasetype == En.PHRASE_TYPE.Verb:
					now.phrasetype = En.PHRASE_TYPE.Infinitive
	return result

class PackedPhrase:
	var phrases:Array[Phrase]
	
	func _init():
		pass
	
	func size():
		return phrases.size()
	
	func append(phrase:Phrase):
		phrases.append(phrase)
	
	func apply(guess:Array):
		var size:int = guess.size()
		for i in range(size):
			var phrase = phrases[guess[i][0]]
			if phrase.size == 1:
				phrase.types[0] = guess[i][2]
			else:
				printerr("apply guess not written")
	
	func _to_string():
		return str(phrases)


class Phrase:
	var phrasetype:int
	var words:PackedStringArray
	var types:PackedStringArray
	var size:int
	
	func _init():
		size = 0
	
	func find_type(type:String, from:int = 0)->int:
		if type.length() == 1:
			for t in range(from, types.size()):
				if types[t][0] == type:
					return t
			return -1
		elif type.length() == 2:
			return types.find(type, from)
		else:
			printerr("invalid find type ", type)
			return -1
	
	func find_type_all(type:String, from:int = 0)->PackedInt64Array:
		var result:PackedInt64Array
		if type.length() == 1:
			for t in range(from, types.size()):
				if types[t][0] == type:
					result.append(t)
		elif type.length() == 2:
			var last = from
			last = types.find(type, last)
			while last != -1:
				result.append(last)
				last = types.find(type, last+1)
		else:
			printerr("invalid find type all ", type)
		return result
	
	func append(word:String, type:String):
		words.append(word)
		types.append(type)
		size += 1
	
	func steal(phrase:Phrase):
		words.append_array(phrase.words)
		types.append_array(phrase.types)
		size += phrase.size
	
	func _to_string():
		var s:String = En.phrase_list[phrasetype] + "["
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
		phrase.phrasetype = En.PHRASE_TYPE.Noun
		if type2 == "P" or type2 == "C":
			while i < limit:
				var next_type = types[i]
				if next_type == type:
					phrase.append(words[i], type)
				else:
					break
				i += 1
			return phrase
		else:
			printerr("Unrecognized ", type)
		return null
	
	static func parse_pronoun(words:PackedStringArray, types:PackedStringArray, index:int, limit:int)->Phrase:
		var phrase:Phrase = Phrase.new()
		var i:int = index
		var type = types[i]
		var type1 = type[0]
		var type2 = type[1]
		if type1 != "P":
			print("not pronoun")
			return null
		phrase.phrasetype = En.PHRASE_TYPE.Pronoun
		phrase.append(words[index], type)
		if type2 == "_":
			return phrase
		elif type2 == "P":
			i += 1
			if i >= limit:
				return phrase
			var next_type = types[i]
			var next_type1 = next_type[0]
			var next_type2 = next_type[1]
			
			if next_type1 == "N":
				var new_phrase = Phrase.parse_noun(words, types, i, limit)
				phrase.steal(
					new_phrase
				)
			elif next_type1 == "J":
				var new_phrase = Phrase.parse_adjective(words, types, i, limit)
				phrase.steal(
					new_phrase
				)
		elif type2 == "R":
			phrase.phrasetype = En.PHRASE_TYPE.Relative
		return phrase
	
	static func parse_verb(words:PackedStringArray, types:PackedStringArray, index:int, limit:int)->Phrase:
		var phrase:Phrase = Phrase.new()
		var i:int = index
		var type = types[i]
		var type1 = type[0]
		var type2 = type[1]
		if type1 != "V":
			print("not verb")
			return null
		phrase.phrasetype = En.PHRASE_TYPE.Verb
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
			pass
		return phrase
	
	static func parse_adjective(words:PackedStringArray, types:PackedStringArray, index:int, limit:int)->Phrase:
		var phrase:Phrase = Phrase.new()
		var new_phrase:Phrase
		var i:int = index
		var type = types[i]
		var type1 = type[0]
		var type2 = type[1]
		if type1 != "J":
			print("not adjective")
			return null
		phrase.append(words[i], type)
		phrase.phrasetype = En.PHRASE_TYPE.Adjective
#		print("adjective", phrase)
		while i < limit:
#			print("i ", i, " ", words[i])
			if phrase.phrasetype == En.PHRASE_TYPE.Noun:
				break
			if type1 == "J":
				if type2 == "A":
					if i+1 >= limit:
						return phrase
					i += 1
					var nexttype = types[i]
					var nexttype1 = nexttype[0]
					var nexttype2 = nexttype[1]
					if nexttype1 == "N":
						new_phrase = Phrase.parse_noun(words, types, i, limit)
						phrase.phrasetype = new_phrase.phrasetype
						phrase.steal(
							new_phrase
						)
						return phrase
					elif nexttype1 == "P":
						new_phrase = Phrase.parse_pronoun(words, types, i, limit)
						phrase.phrasetype = new_phrase.phrasetype
						phrase.steal(
							new_phrase
						)
						return phrase
					elif nexttype1 == "J":
						new_phrase = Phrase.parse_adjective(words, types, i, limit)
						phrase.phrasetype = new_phrase.phrasetype
						phrase.steal(
							new_phrase
						)
						i += new_phrase.size
						continue
					elif nexttype1 == "B":
						new_phrase = Phrase.parse_adverb(words, types, i, limit)
						phrase.phrasetype = new_phrase.phrasetype
						phrase.steal(
							new_phrase
						)
						i += new_phrase.size
						continue
				elif type2 == "_":
					if i+1 >= limit:
						return phrase
					i += 1
					var nexttype = types[i]
					var nexttype1 = nexttype[0]
					var nexttype2 = nexttype[1]
					if nexttype1 == "N":
						new_phrase = Phrase.parse_noun(words, types, i, limit)
						phrase.phrasetype = new_phrase.phrasetype
						phrase.steal(
							new_phrase
						)
#						print("back ", words[i])
						return phrase
					elif nexttype1 == "P":
						new_phrase = Phrase.parse_pronoun(words, types, i, limit)
						phrase.phrasetype = new_phrase.phrasetype
						phrase.steal(
							new_phrase
						)
						return phrase
					elif nexttype1 == "J":
						new_phrase = Phrase.parse_adjective(words, types, i, limit)
						phrase.phrasetype = new_phrase.phrasetype
						phrase.steal(
							new_phrase
						)
						i += new_phrase.size
						continue
					elif nexttype1 == "B":
						new_phrase = Phrase.parse_adverb(words, types, i, limit)
						phrase.phrasetype = new_phrase.phrasetype
						phrase.steal(
							new_phrase
						)
						i += new_phrase.size
						continue
			else:
				break
			i += 1
		return phrase
	
	static func parse_adverb(words:PackedStringArray, types:PackedStringArray, index:int, limit:int)->Phrase:
		var phrase:Phrase = Phrase.new()
		var i:int = index
		var type = types[i]
		var type1 = type[0]
		var type2 = type[1]
		if type1 != "B":
			print("not adverb")
			return null
		phrase.phrasetype = En.PHRASE_TYPE.Adverb
		phrase.append(words[i], type)
		if type2 == "V":
			i += 1
			if i >= limit:
				return phrase
			var next_type = types[i]
			var next_type1 = next_type[0]
			var next_type2 = next_type[1]
			if next_type1 == "V":
				var new_phrase = Phrase.parse_verb(words, types, i, limit)
				phrase.phrasetype = new_phrase.phrasetype
				phrase.steal(
					new_phrase
				)
		elif type2 == "M":
			i += 1
			if i >= limit:
				return phrase
			var next_type = types[i]
			var next_type1 = next_type[0]
			var next_type2 = next_type[1]
			if next_type1 == "J":
				var new_phrase = Phrase.parse_adjective(words, types, i, limit)
				phrase.phrasetype = new_phrase.phrasetype
				phrase.steal(
					new_phrase
				)
#				print("back ", phrase)
			elif next_type1 == "B":
				var new_phrase = Phrase.parse_adverb(words, types, i, limit)
				phrase.phrasetype = new_phrase.phrasetype
				phrase.steal(
					new_phrase
				)
		elif type2 == "E":
			i += 1
			if i >= limit:
				return phrase
			var next_type = types[i]
			var next_type1 = next_type[0]
			var next_type2 = next_type[1]
			if next_type1 == "B":
				if next_type2 == "E":
					var new_phrase = Phrase.parse_adverb(words, types, i, limit)
					phrase.phrasetype = new_phrase.phrasetype
					phrase.steal(
						new_phrase
					)
		return phrase
	
	static func parse_preposition(words:PackedStringArray, types:PackedStringArray, index:int, limit:int)->Phrase:
		var phrase:Phrase = Phrase.new()
		var i:int = index
		var type = types[i]
		var type1 = type[0]
		var type2 = type[1]
		if type1 != "R":
			return null
		phrase.phrasetype = En.PHRASE_TYPE.Prepositional
		phrase.append(words[i], type)
		return phrase
	
	static func parse_conjunction(words:PackedStringArray, types:PackedStringArray, index:int, limit:int)->Phrase:
		var phrase:Phrase = Phrase.new()
		var i:int = index
		var type = types[i]
		var type1 = type[0]
		var type2 = type[1]
		if type1 != "C":
			return null
		phrase.phrasetype = En.PHRASE_TYPE.Conjunctive
		phrase.append(words[i], type)
		return phrase
	
	static func parse_symbol(words:PackedStringArray, types:PackedStringArray, index:int, limit:int)->Phrase:
		var type = types[index]
		var type1 = type[0]
		var type2 = type[1]
		if not type1 in SYMBOLS:
			return null
		var phrase:Phrase = Phrase.new()
		phrase.phrasetype = En.PHRASE_TYPE.Symbol
		phrase.append(words[index], type)
		return phrase
	
	
