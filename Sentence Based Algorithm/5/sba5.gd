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

func read(packedphrase:AP2.PackedPhrase, index:DS.Pointer = DS.Pointer.new()):
	var sentence:Sentence = Sentence.new()
	var clause:Array[Dictionary]
	index.data = -1
	var limit:int = packedphrase.size()
	var phrases:Array[AP2.Phrase] = packedphrase.phrases
	while index.data+1 < limit:
		index.data += 1
		var phrase = phrases[index.data]
		if (phrase.phrasetype == En.PHRASE_TYPE.Noun
			or 
			phrase.phrasetype == En.PHRASE_TYPE.Pronoun):
			var noun = eat_nouns(phrases, index, limit)
			if not clause_has(clause, "subject"):
				noun["@"] = "subject"
			else:
				noun["@"] = "noun?"
			clause.append(noun)
		elif phrase.phrasetype == En.PHRASE_TYPE.Verb:
			var verb = eat_verb(phrases, index, limit)
			if clause_has(clause, "verb"):
				verb["@"] = "verb?"
			clause.append(verb)
		elif phrase.phrasetype == En.PHRASE_TYPE.Relative:
			clause.append({
				"@": "relative",
				"$": phrase.words[0]
			})
		elif phrase.phrasetype == En.PHRASE_TYPE.Adverb:
			clause.append({
				"@": "adverb",
				"$": phrase.words.duplicate()
			})
		elif phrase.phrasetype == En.PHRASE_TYPE.Prepositional:
			var preposition = eat_preposition(phrases, index, limit)
			clause.append(preposition)
		elif phrase.phrasetype == En.PHRASE_TYPE.Conjunctive:
			sentence.clauses.append(clause)
			clause = []
			clause.append({
				"@": "conjunction",
				"$": phrase.words[0]
			})
		elif phrase.phrasetype == En.PHRASE_TYPE.Infinitive:
			var infinitive = eat_infinitive(phrases, index, limit)
			clause.append(infinitive)
		else:
			printerr("uncacthed! ", En.phrase_list[phrase.phrasetype])
	sentence.clauses.append(clause)
	return sentence

func eat_noun(phrase:AP2.Phrase):
	var words:PackedStringArray = phrase.words
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
			value[i] = words[ nouns[i] ]
		clause["$"] = value
		clause["J"] = digest_adjectives(phrase)
		return clause
	elif phrase.phrasetype == En.PHRASE_TYPE.Pronoun:
		var clause = create_noun("P")
		var pronoun = phrase.find_type("P")
		if pronoun == -1:
			printerr("invalid pronoun")
			return null
		clause["P"] = words[pronoun]
		clause["J"] = digest_adjectives(phrase)
		var nouns = phrase.find_type_all("NC")
		if nouns.is_empty():
			nouns = phrase.find_type_all("NP")
		if not nouns.is_empty():
			var value:PackedStringArray
			value.resize(nouns.size())
			for i in range(nouns.size()):
				value[i] = words[ nouns[i] ]
			clause["$"] = value
		return clause
	elif phrase.phrasetype == En.PHRASE_TYPE.Adjective:
		var clause = {
			"#": "J"
		}
		var adverb = phrase.find_type("B")
		if adverb != -1:
			clause["B"] = words[adverb]
		var adjective = phrase.find_type("J")
		if adjective == -1:
			printerr("false adjective phrase")
		clause["$"] = words[adjective]
		return clause
	else:
		printerr("invalid noun phrase!")

func eat_nouns(phrases:Array[AP2.Phrase], index:DS.Pointer, limit:int):
	var nouns:Dictionary
	var conjunction:String
	var nouns_p:Array
	var noun
	var i:int = index.data
	var phrase:AP2.Phrase = phrases[i]
	if phrase.phrasetype == En.PHRASE_TYPE.Noun:
		noun = eat_noun(phrase)
		nouns_p.append(noun)
	elif phrase.phrasetype == En.PHRASE_TYPE.Pronoun:
		noun = eat_noun(phrase)
		nouns_p.append(noun)
	elif phrase.phrasetype == En.PHRASE_TYPE.Adjective:
		noun = eat_noun(phrase)
		nouns_p.append(noun)
	else:
		return null
	i += 1
	while i < limit:
		print(i)
		phrase = phrases[i]
		if phrase.phrasetype == En.PHRASE_TYPE.Symbol:
			if phrase.types[0] != ",E":
				break
			i += 1
			if i >= limit:
				break
			var nextphrase = phrases[i]
			if nextphrase.phrasetype == En.PHRASE_TYPE.Noun:
				noun = eat_noun(nextphrase)
				nouns_p.append(noun)
			elif nextphrase.phrasetype == En.PHRASE_TYPE.Pronoun:
				noun = eat_noun(nextphrase)
				nouns_p.append(noun)
			elif nextphrase.phrasetype == En.PHRASE_TYPE.Adjective:
				noun = eat_noun(nextphrase)
				nouns_p.append(noun)
			elif nextphrase.phrasetype == En.PHRASE_TYPE.Conjunctive:
				if nextphrase.types[0] != "CE":
					break
				conjunction = nextphrase.words[0]
				i += 1
				if i >= limit:
					break
				phrase = phrases[i]
				if phrase.phrasetype == En.PHRASE_TYPE.Noun:
					noun = eat_noun(phrase)
					nouns_p.append(noun)
				elif phrase.phrasetype == En.PHRASE_TYPE.Pronoun:
					noun = eat_noun(phrase)
					nouns_p.append(noun)
				elif phrase.phrasetype == En.PHRASE_TYPE.Adjective:
					noun = eat_noun(phrase)
					nouns_p.append(noun)
				else:
					printerr("WTF")
				index.data = i
				break
		elif phrase.phrasetype == En.PHRASE_TYPE.Conjunctive:
			if phrase.types[0] != "CE":
				break
			conjunction = phrase.words[0]
			i += 1
			if i >= limit:
				break
			var nextphrase = phrases[i]
			if nextphrase.phrasetype == En.PHRASE_TYPE.Noun:
				noun = eat_noun(nextphrase)
				nouns_p.append(noun)
			elif nextphrase.phrasetype == En.PHRASE_TYPE.Pronoun:
				noun = eat_noun(nextphrase)
				nouns_p.append(noun)
			elif nextphrase.phrasetype == En.PHRASE_TYPE.Adjective:
				noun = eat_noun(nextphrase)
				nouns_p.append(noun)
			index.data = i
			break
		else:
			break
		i += 1
#	print(nouns_p.size())
	if nouns_p.size() == 1:
		nouns = {
			"@": null,
			"$": nouns_p[0]
		}
	else:
		nouns = {
			"@": null,
			"C": conjunction,
			"$": nouns_p
		}
	
	return nouns

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
					create_adjective(words[i], words[i-1])
				)
	return clauses

func eat_verb(phrases:Array[AP2.Phrase], index:DS.Pointer, limit:int):
	var phrase:AP2.Phrase = phrases[index.data]
	if phrase.phrasetype != En.PHRASE_TYPE.Verb:
		printerr("false verb phrase")
	var words:PackedStringArray = phrase.words
	var verb = create_verb()
	var type:String
	var modal = phrase.find_type("VM")
	if modal != -1:
		type += "M"
		verb["M"] = words[modal]
	var auxilary = phrase.find_type("VA")
	if auxilary != -1:
		type += "A"
		verb["A"] = words[auxilary]
	var verbs = phrase.find_type_all("V_")
	if not verbs.is_empty():
		type += "V"
		var verbs_p:PackedStringArray
		verbs_p.resize(verbs.size())
		for v in range(verbs.size()):
			verbs_p[v] = words[ verbs[v] ]
		verb["$"] = verbs_p
	
	index.data += 1
	if index.data >= limit:
		index.data -= 1
		return verb
	var nextphrase = phrases[index.data]
	if nextphrase.phrasetype == En.PHRASE_TYPE.Noun:
		var noun = eat_nouns(phrases, index, limit)
		noun["@"] = "object"
		verb["O"] = noun
	elif nextphrase.phrasetype == En.PHRASE_TYPE.Pronoun:
		var noun = eat_nouns(phrases, index, limit)
		noun["@"] = "object"
		verb["O"] = noun
	elif nextphrase.phrasetype == En.PHRASE_TYPE.Adjective:
		var noun = eat_nouns(phrases, index, limit)
		noun["@"] = "object"
		verb["O"] = noun
	else:
		index.data -= 1
	return verb

func eat_preposition(phrases:Array[AP2.Phrase], index:DS.Pointer, limit:int):
	var phrase:AP2.Phrase = phrases[index.data]
	if phrase.phrasetype != En.PHRASE_TYPE.Prepositional:
		printerr("false verb phrase")
	var words:PackedStringArray = phrase.words
	var preposition:Dictionary = {
		"@": "preposition",
		"$": words[0],
		"O": null
	}
	index.data += 1
	if index.data >= limit:
		index.data -= 1
		return preposition
	var nextphrase = phrases[index.data]
	if nextphrase.phrasetype == En.PHRASE_TYPE.Noun:
		var noun = eat_nouns(phrases, index, limit)
		noun["@"] = "object"
		preposition["O"] = noun
	elif nextphrase.phrasetype == En.PHRASE_TYPE.Pronoun:
		var noun = eat_nouns(phrases, index, limit)
		noun["@"] = "object"
		preposition["O"] = noun
	elif nextphrase.phrasetype == En.PHRASE_TYPE.Adjective:
		var noun = eat_nouns(phrases, index, limit)
		noun["@"] = "object"
		preposition["O"] = noun
	else:
		index.data -= 1
	return preposition

func eat_infinitive(phrases:Array[AP2.Phrase], index:DS.Pointer, limit:int):
	var phrase:AP2.Phrase = phrases[index.data]
	if phrase.phrasetype != En.PHRASE_TYPE.Infinitive:
		printerr("false verb phrase")
	var words:PackedStringArray = phrase.words
	var infinitive:Dictionary = {
		"@": "infinitive",
		"$": words[0]
	}
	index.data += 1
	if index.data >= limit:
		index.data -= 1
		return infinitive
	var nextphrase = phrases[index.data]
	if nextphrase.phrasetype == En.PHRASE_TYPE.Verb:
		var verb = eat_verb(phrases, index, limit)
		infinitive["V"] = verb
	else:
		printerr("false infinitive")
		return null
	return infinitive

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
		"T": "",
		"B<": "",
		"M": "",
		"A": "",
		"$": [],
		"O": null,
		"B>": ""
	}

func create_adjective(value:String, adverb = null)->Dictionary:
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

func clause_has(clause:Array[Dictionary], part:String):
	for c in clause:
		if c["@"] == part:
			return true

class Sentence:
	var sentence:String
	var clauses:Array
	
	func has_part(part_s:String):
		for sentence in clauses:
			for clause in sentence:
				if clause["@"] == part_s:
					return true
		return false
	
	func to_str()->String:
		var s:String = JSON.stringify(
			clauses, "\t", false
		)
		return s
	
	func _to_string():
		return to_str()
	
