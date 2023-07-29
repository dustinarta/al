extends RefCounted
class_name SBA3

var sentences

func _init():
	sentences = []

func read(input:String):
	var collection = English.read(input)
	var limit:int = collection.elements.size() - 1
	var ptr = DS.Pointer.new().write(0)
	while ptr.data < limit:
		var clause = parse_phrase(collection, ptr)

func parse_phrase(collection:English.Collection, from:DS.Pointer = DS.Pointer.new().write(0)):
	var subject = PhraseNounBig.new()
	var verb
	var object = PhraseNounBig.new()
	var preposition
	var conjunction
	
	var aftercomma:bool = false
	var canbesentence:bool = false
	
	while from.data < collection.elements.size():
	#for s in collection.elements:
		var s = collection.elements[from.data]
		if s is English.SC:
			var sc = s as English.SC
			if sc.c == ",":
				aftercomma = true
		elif s is English.Phrase:
			var phrase = s as English.Phrase
			if phrase.type == En.PHRASE_TYPE.Noun:
				var thisclause:PhraseNounBig = eat_nouns(collection.elements, from)
				print("result noun = ", thisclause)
				if verb == null:
					subject = thisclause
				else:
					object = thisclause
			elif phrase.type == En.PHRASE_TYPE.Pronoun:
				var thisclause:PhraseNounBig = eat_nouns(collection.elements, from)
				print("result pronoun = ", thisclause)
				if verb == null:
					subject = thisclause
				else:
					object = thisclause
			elif phrase.type == En.PHRASE_TYPE.Verb:
				var thisclause:PhraseVerb = eat_verb(phrase)
				verb = thisclause
			elif phrase.type == En.PHRASE_TYPE.Prepositional:
				print("catch preposition")
				var thisclause:PhrasePreposition = eat_preposition(collection.elements, from)
				preposition = thisclause
		from.data += 1
	print(subject)
	print(verb)
	print(object)
	print(preposition)
	var clause = ClauseIndependent.new()
	clause.subject = subject
	clause.verb = verb
	clause.object = object
	return clause

func eat_adverb(phrase:English.Phrase):
	var thisclause:PhraseAdverb = PhraseAdverb.new()
	if phrase.type == En.PHRASE_TYPE.Adverb:
		thisclause.main = phrase.speech
		return thisclause
	else:
		var adverbs = phrase.find_speech_all(En.SPEECH_TYPE.Adverb)
		if adverbs.is_empty():
			return null
		thisclause.main.append(phrase.speech[0] )
		return thisclause
	return null

func eat_adjectives(phrase:English.Phrase):
	var adjectives = phrase.find_speech_all(En.SPEECH_TYPE.Adjective)
	if adjectives.is_empty():
		return []
	var thisclauses:Array[PhraseAdjective]
	var thisclause:PhraseAdjective = PhraseAdjective.new()
	var str:PackedStringArray
	str.resize(adjectives.size())
	thisclauses.resize(adjectives.size())
	for adj in range(adjectives.size()):
		thisclause = PhraseAdjective.new()
		thisclause.main = [ phrase.speech[adjectives[adj]] ]
		thisclauses[adj] = thisclause
	return thisclauses

func eat_verb(phrase:English.Phrase):
	var thisclause:PhraseVerb = PhraseVerb.new()
	var str:PackedStringArray
	var verbs = phrase.find_speech_all(En.SPEECH_TYPE.Verb)
	var verb_count = verbs.size()
	if verb_count == 0:
		return null
	elif verb_count == 1:
		thisclause.main.append( phrase.speech[0] )
	else:
		var modal = phrase.find_speech_type(En.SPEECH_TYPE.Verb, En.Verb.Modal)
		if modal != -1:
			thisclause.modal = phrase.speech[modal]
		else:
			var helping = phrase.find_speech_type_all(En.SPEECH_TYPE.Verb, En.Verb.Auxiliary)
			if helping.size() == verb_count:
				for help in range(helping.size()-1):
					thisclause.helping.append(phrase.speech[helping[help]])
				thisclause.main.append( phrase.speech[helping.last()] )
	return thisclause

func eat_nouns(elements:Array, from:DS.Pointer):
	var thisclause:PhraseNounBig = PhraseNounBig.new()
	var newclause
	var conjunction
	var limit = elements.size()
	var running:bool = true
	var usecomma:bool = false
	var aftercomma:bool = false
	var last:bool = false
	
	var s = elements[from.data]
	if s is English.Phrase:
		var phrase = s as English.Phrase
		if phrase.type == En.PHRASE_TYPE.Noun:
			newclause = eat_noun(phrase)
		elif phrase.type == En.PHRASE_TYPE.Pronoun:
			newclause = eat_pronoun(phrase)
		else:
			return null
		thisclause.append(newclause)
	from.data += 1
	while from.data < limit:
		s = elements[from.data]
		newclause == null
		if s is English.Phrase:
			var phrase = s as English.Phrase
			if phrase.type == En.PHRASE_TYPE.Noun:
				newclause = eat_noun(phrase)
			elif phrase.type == En.PHRASE_TYPE.Pronoun:
				newclause = eat_pronoun(phrase)
			elif phrase.type == En.PHRASE_TYPE.Conjunctive:
				conjunction = eat_conjunction(phrase)
				last = true
				from.data += 1
				continue
			else:
				if thisclause.element_count == 1:
					from.data -= 1
					break
			if newclause != null:
				if last:
					thisclause.conjunction = conjunction
					thisclause.append(newclause)
					return thisclause
				elif aftercomma:
					thisclause.append(newclause)
					print("appending ", newclause)
					aftercomma = false
				else:
					printerr("weird flow ", thisclause.elements[0])
					return null
			else:
				printerr("weird flow", thisclause.elements[0])
				return null
		elif s is English.SC:
			var sc = s as English.SC
			if sc.c == ",":
				aftercomma = true
				usecomma = true
			else:
				break
		from.data += 1
		if from.data >= limit:
			break
	return thisclause

func eat_noun(phrase:English.Phrase):
	var thisclause:PhraseNoun = PhraseNoun.new()
	var str:PackedStringArray
	var nouns = phrase.find_speech_type_all(En.SPEECH_TYPE.Noun, En.Noun.Common)
	if nouns.is_empty():
		nouns = phrase.find_speech_type_all(En.SPEECH_TYPE.Noun, En.Noun.Proper)
	## return nothing
	if nouns.is_empty():
		return null
	
	var noun_size:int = nouns.size()
	str.resize(noun_size)
	for n in range(noun_size):
		str[n] = phrase.speech[nouns[n]]
	thisclause.main = str
	thisclause.adjectives = eat_adjectives(phrase)
	return thisclause

func eat_pronoun(phrase:English.Phrase):
	if !phrase.type == En.PHRASE_TYPE.Pronoun:
		return null
	
	var thisclause:PhrasePronoun = PhrasePronoun.new()
	var pronoun_type = phrase.speechtype[0][1]
	thisclause.main = [ phrase.speech[0] ]
	if phrase.count > 1:
		thisclause.noun = eat_noun(phrase)
	return thisclause

func eat_conjunction(phrase:English.Phrase):
	var thisclause:PhraseConjunction = PhraseConjunction.new()
	var c_i:int = phrase.find_speech(En.SPEECH_TYPE.Conjunction)
	if c_i == -1:
		return null
	thisclause.main = [phrase.speech[c_i]]
	return thisclause

func eat_preposition(elements:Array, from:DS.Pointer):
	var phrase = elements[from.data]
	var p_i = phrase.find_speech(En.SPEECH_TYPE.Preposition)
	if p_i == -1:
		return null
	
	var thisclause:PhrasePreposition = PhrasePreposition.new()
	thisclause.main = [phrase.speech[p_i]]
	
	from.data += 1
	if from.data < elements.size():
		phrase = elements[from.data]
		thisclause.emptypreposition = false
		if phrase.type == En.PHRASE_TYPE.Noun:
			thisclause.noun = eat_noun(phrase)
		elif phrase.type == En.PHRASE_TYPE.Pronoun:
			thisclause.noun = eat_pronoun(phrase)
		else:
			thisclause.emptypreposition = true
			from.data -= 1
	else:
		thisclause.emptypreposition = true
		from.data -= 1
	return thisclause

class Clause:
	var subject
	var end:String

class ClauseComplete:
	extends Clause
	
	var verb:PhraseVerb
	var object:PhraseNounBig
	#var prepositions

class ClauseIndependent:
	extends ClauseComplete

class ClauseDependent:
	extends ClauseComplete
	var conjunction:PhraseConjunction

class Phrase:
	var main:PackedStringArray#: set = set_main
	#var empty:bool = true
	#
	#func set_main(new_main):
	#	main = new_main
	#	empty = false
	
	func is_null():
		return main.is_empty()
	
	func to_str()->String:
		return " ".join(main)
	
	func _to_string():
		return to_str()

class PhraseVerb:
	extends Phrase
	
	var adverb:PhraseAdverb
	var helping
	var modal
	
	func to_str()->String:
		if helping:
			return " ".join(helping) + " ".join(main)
		if modal:
			return modal + " ".join(main)
		return " ".join(main)

class PhrasePronoun:
	extends Phrase
	
	var noun:PhraseNoun
	
	func to_str():
		if noun == null:
			return " ".join(main)
		else:
			return " ".join(main) + " " + noun.to_str()

class PhraseNounBig:
	var elements:Array[Phrase]
	var element_count:int
	var conjunction:PhraseConjunction
	
	func append(phrase:Phrase):
		elements.append(phrase)
		element_count += 1
	
	func is_empty()->bool:
		return element_count == 0
	
	func _to_string():
		return to_str()
	
	func to_str()->String:
		var s:String = ""
		if element_count == 0:
			return "<null>"
		if element_count == 1:
			return elements[0].to_str()
		elif element_count == 2:
			return elements[0].to_str() + " " + conjunction.to_str() + " " + elements[1].to_str()
		else:
			for i in range(element_count-1):
				s += elements[i].to_str() + ", "
			s += conjunction.to_str() + " " + elements[-1].to_str()
		return s

class PhraseNoun:
	extends Phrase
	var adjectives:Array
	var noun_type
	
	func to_str()->String:
		var s:String = ""
		for adj in adjectives:
			s += adj.to_str() + " "
		return s + " ".join(main)

class PhraseAdjective:
	extends Phrase
	var adverb:PhraseAdverb
	
	func to_str()->String:
		if adverb != null:
			return adverb.to_str() + " ".join(main)
		else:
			return " ".join(main)

class PhraseAdverb:
	extends Phrase

class PhraseConjunction:
	extends Phrase

class PhrasePreposition:
	extends Phrase
	var noun:Phrase
	var emptypreposition:bool = true
	
	func to_str():
		if emptypreposition:
			return super.to_str()
		else:
			return super.to_str() + " " + noun.to_str()
