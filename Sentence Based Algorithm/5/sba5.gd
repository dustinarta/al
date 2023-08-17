extends RefCounted
class_name SBA5

var ap:AP2

func _init():
	pass

func init_ap():
	ap = AP2.new()
	ap.load("res://Attention Parser/2/data.json")

func read_s(sentence:String):
	return read(ap.parse_phrase_s(sentence))

func read(packedphrase:AP2.PackedPhrase):
	var index:DS.Pointer = DS.Pointer.new()
	index.data = -1
	var limit:int = packedphrase.size()
	var phrases:Array[AP2.Phrase] = packedphrase.phrases
	while index.data+1 < limit:
		index.data += 1
		var phrase = phrases[index.data]
		if phrase.phrasetype == En.PHRASE_TYPE.Noun:
			var noun = eat_nouns(phrases, index)
			return noun
	

func eat_noun(phrase:AP2.Phrase):
	if phrase.phrasetype == En.PHRASE_TYPE.Noun:
		var clause = create_noun("N")
		var nouns = phrase.find_type_all("NC")
		if nouns.is_empty():
			nouns = phrase.find_type_all("NP")
		if nouns.is_empty():
			printerr("invalid nouns")
			return null
		var value:PackedStringArray
		value.resize(nouns.size())
		for i in range(nouns.size()):
			value[i] = phrase.words[ nouns[i] ]
		clause["$"] = value
		clause["J"] = digest_adjectives(phrase)
		return clause

func eat_nouns(phrases:Array[AP2.Phrase], index:DS.Pointer):
	var limit:int = phrases.size()
	while index.data < limit:
		var phrase:AP2.Phrase = phrases[index.data]
		if phrase.phrasetype == En.PHRASE_TYPE.Noun:
			return eat_noun(phrase)
		index.data += 1

func digest_adjectives(phrase:AP2.Phrase):
	var clauses:Array
	var words:PackedStringArray = phrase.words
	var types:PackedStringArray = phrase.types
	var limit:int = phrase.size
	var i:int = -1
	while i+1 < limit:
		i += 1
		var type = types[i]
		var type1 = type[0]
		var type2 = type[1]
		if type1 == "J":
			clauses.append(
				create_adjective(words[i])
			)
			continue
		elif type1 == "B":
			i += 1
			if i >= limit:
				printerr("false adverb")
				return null
			var nexttype = types[i]
			var nexttype1 = nexttype[0]
			var nexttype2 = nexttype[1]
			if nexttype1 == "J":
				clauses.append(
					create_adjective(words[i-1], words[i])
				)
	return clauses

func create_noun(type_s:String)->Dictionary:
	return {
		"#": type_s,
		"J": [],
		"$": []
	}

func create_part(part_s:String = "")->Dictionary:
	return {
		"@": part_s,
		"$": null
	}

func create_subject_single()->Dictionary:
	return {
		"@": "subject",
		"$": null
	}

func create_subject_multy()->Dictionary:
	return {
		"@": "subject",
		"C": "",
		"$": []
	}

func create_verb()->Dictionary:
	return {
		"@": "verb",
		"B<": "",
		"M": "",
		"A": "",
		"$": [],
		"O": null,
		"B>": ""
	}

func create_adjective(value:String, adverb:String = "")->Dictionary:
	return {
		"#": "J",
		"B": adverb,
		"$": value
	}

func create_conjunction()->Dictionary:
	return {
		"@": "conjunction",
		"$": "",
	}

func create_preposition()->Dictionary:
	return {
		"@": "preposition",
		"$": "",
		"O": null
	}

class Sentence:
	var sentence:String
	var data:Array
	
	func has_part(part_s:String):
		for sentence in data:
			for clause in sentence:
				if clause["@"] == part_s:
					return true
		return false
	
