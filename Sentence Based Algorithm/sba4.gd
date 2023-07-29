@tool
extends Node

func read(input:String):
	var collection = English.read(input)
	var limit:int = collection.elements.size() - 1
	var ptr = DS.Pointer.new().write(0)
	while ptr.data < limit:
		if ptr.data < limit:
			var clause = parse_phrase(collection, ptr)
			continue
		break

func parse_phrase(collection:English.Collection, from:DS.Pointer = DS.Pointer.new().write(0)):
	var subject = PhraseNounBig.new()
	var verb
	var object = PhraseNounBig.new()
	var conjunction
	
	var aftercomma:bool = false
	var canbesentence:bool = false
	
	var s_i:int = from.data
	while s_i < collection.elements.size():
#	for s in collection.elements:
		var s = collection.elements[s_i]
		if s is English.SC:
			var sc = s as English.SC
			if sc.c == ",":
				aftercomma = true
		elif s is English.Phrase:
			var phrase = s as English.Phrase
			if phrase.type == En.PHRASE_TYPE.Noun:
				var thisclause:PhraseNoun = PhraseNoun.new()
				var str:PackedStringArray
				var nouns = phrase.find_speech_type_all(En.SPEECH_TYPE.Noun, En.Noun.Common)
				if nouns.is_empty():
					nouns = phrase.find_speech_type_all(En.SPEECH_TYPE.Noun, En.Noun.Proper)
				str.resize(nouns.size())
				for n in range(nouns.size()):
					str[n] = phrase.speech[nouns[n]]
				thisclause.main = str
				thisclause.adjectives = eat_adjectives(phrase)
				if aftercomma:
					if verb == null:
						subject.append(thisclause)
						
					aftercomma = false
				else:
					if verb == null:
						subject.append(thisclause)
					else:
						object.append(thisclause)
			elif phrase.type == En.PHRASE_TYPE.Pronoun:
				var thisclause:PhrasePronoun = PhrasePronoun.new()
				if phrase.count == 1:
					var pronoun_type = phrase.speechtype[0][1]
					thisclause.main = [ phrase.speech[0] ]
				else:
					printerr("unhandled else pronoun")
				if verb == null:
					subject.append(thisclause)
				else:
					object.append(thisclause)
			elif phrase.type == En.PHRASE_TYPE.Verb:
				var thisclause:PhraseVerb = PhraseVerb.new()
				var str:PackedStringArray
				var verbs = phrase.find_speech_all(En.SPEECH_TYPE.Verb)
				var verb_count = verbs.size()
				if verb_count == 1:
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
				verb = thisclause
		s_i += 1
	print(subject)
	print(verb)
	print(object)
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
		return null
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
	var main:PackedStringArray: set = set_main
	var empty:bool = true
	
	func set_main(main):
		self.main = main
		empty = false
	
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
			return "null"
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
	var adjectives:Array[PhraseAdjective]
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
