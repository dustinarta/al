extends RefCounted
class_name SBA4

var ap2:AP2

func _init():
	ap2 = AP2.new()
	ap2.load("res://Attention Parser/2/data.json")

func read_s(sentence:String):
	var packedpharse:AP2.PackedPhrase = ap2.parse_phrase_s(sentence)
	return phrases_to_clause(packedpharse.phrases)

func phrases_to_clause(phrases:Array[AP2.Phrase], index:DS.Pointer = DS.Pointer.new().write(0)):
	var subject:ClauseNoun
	var verb:PhraseVerb
	var object:ClauseNoun
	
	var limit:int = phrases.size()
	while index.data < limit:
		var phrase:AP2.Phrase = phrases[index.data]
		
		if phrase.phrasetype == En.PHRASE_TYPE.Noun:
			var noun = eat_nouns(phrases, index)
			print(noun)
			
			continue
#		print("konjiwnc")
		index.data += 1

func eat_noun(phrase:AP2.Phrase):
	if phrase.phrasetype != En.PHRASE_TYPE.Noun:
		return null
	var thisphrase:PhraseNoun = PhraseNoun.new()
	var nouns = phrase.find_type_all("NP")
	if nouns.is_empty():
		nouns = phrase.find_type_all("NC")
		if nouns.is_empty():
			printerr("empty noun!")
			return null
	var words = phrase.words
	var newmain:PackedStringArray
	newmain.resize(nouns.size())
	for n in range(nouns.size()):
		newmain[n] = words[nouns[n]]
	thisphrase.main = newmain
	thisphrase.adjectives = digest_adjectives(phrase)
	return thisphrase

func digest_adjectives(phrase:AP2.Phrase):
	var thisadjectives:Array
	var words = phrase.words
	var adjectives = phrase.find_type_all("J")
	if not adjectives.is_empty():
		thisadjectives.resize(adjectives.size())
		for adj in range(adjectives.size()):
			var adjective = PhraseAdjective.new()
			adjective.main = [words[adjectives[adj]]]
			thisadjectives[adj] = adjective
	return thisadjectives

func eat_verb(phrase:AP2.Phrase):
	if phrase.phrasetype != En.PHRASE_TYPE.Verb:
		return null
	var thisphrase:PhraseVerb = PhraseVerb.new()
	var words = phrase.words
	var verbs = phrase.find_type_all("V_")
	if not verbs.is_empty():
		var word_verb:PackedStringArray
		word_verb.resize(verbs.size())
		for i in range(verbs.size()):
			word_verb[i] = words[verbs[i]]
		thisphrase.main = word_verb
	var auxilary = phrase.find_type("VA")
	if auxilary != -1:
		if verbs.is_empty():
			thisphrase.main = [ words[auxilary] ]
		else:
			thisphrase.helping = [ words[auxilary] ]

func eat_nouns(phrases:Array[AP2.Phrase], index:DS.Pointer):
	var thisclause:ClauseNoun = ClauseNoun.new()
	var phrase:AP2.Phrase = phrases[index.data]
	var noun = eat_noun(phrase)
	thisclause.append_element(noun)
	index.data += 1
	var aftercomma:bool = false
	var conjunction:PhraseConjunction
	var limit:int = phrases.size()
	while index.data < limit:
		phrase = phrases[index.data]
		if phrase.phrasetype == En.PHRASE_TYPE.Noun:
			if conjunction == null:
				printerr("double noun")
				break
			noun = eat_noun(phrase)
			thisclause.append_element(noun)
			index.data += 1
			break
		elif phrase.phrasetype == En.PHRASE_TYPE.Conjunctive:
			conjunction = eat_conjunction(phrase)
			thisclause.conjunction = conjunction
		else:
			break
		index.data += 1
	return thisclause

func eat_conjunction(phrase:AP2.Phrase):
	if phrase.phrasetype != En.PHRASE_TYPE.Conjunctive:
		return null
	var thisphrase:PhraseConjunction = PhraseConjunction.new()
	thisphrase.main = phrase.words.duplicate()
	return thisphrase

class Sentence:
	var clauses:Array[ClauseSentence]
	
	func append(clause:ClauseSentence):
		clauses.append(clause)
	
	func to_str():
		var s:String = ""
		for clause in clauses:
			s += clause.to_str() + clause.end
		return s
	
	func _to_string():
		return to_str()

class ClauseSentence:
	var subject:ClausePhraseBig
	var end:String
	
	func to_str():
		pass
	
	func _to_string():
		return to_str()

class ClauseIndependent:
	extends ClauseSentence
	
	var verb:ClauseVerb
	var prepositions:Array[PhrasePreposition]
	
	func to_str():
		var s:String = ""
		if !subject.is_empty():
			s += subject.to_str() + " "
		if !verb.is_null():
			s += verb.to_str() + " "
			if verb.object != null:
				s += verb.object.to_str() + " "
		if !prepositions.is_empty():
			for preposition in prepositions:
				s += preposition.to_str() + " "
		return s

class ClauseDependent:
	extends ClauseIndependent
	var conjunction:PhraseConjunction
	
	func to_str():
		var s:String = conjunction.to_str() + " " + super.to_str()
		return s

class ClausePhrase:
	func to_str():
		pass
	func _to_string():
		return to_str()

class ClausePhraseSmall:
	extends ClausePhrase
	var element:Phrase
	
	func to_str()->String:
		if element:
			return element.to_str()
		else:
			return "<null>"

class ClausePhraseBig:
	extends ClausePhrase
	var elements:Array[Phrase]
	var element_count:int
	var conjunction:PhraseConjunction
	
	func append_element(element:Phrase):
		elements.append(element)
		element_count = elements.size()
	
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

## Include noun phrase and pronoun phrase
class ClauseNoun:
	extends ClausePhraseBig

class ClauseVerb:
	extends ClausePhraseSmall
	
	var object:ClausePhrase

class ClausePreposition:
	extends ClausePhraseSmall
	
	var noun:ClauseNoun

class Phrase:
	var main:PackedStringArray#: set = set_main
	#var empty:bool = true
	#
	#func set_main(new_main):
	#	main = new_main
	#	empty = false
	
	func _init(words:PackedStringArray = []):
		main = words
	
	func append_main(word):
		main.append(word)
	
	func is_null():
		return main.is_empty()
	
	func to_str()->String:
		return " ".join(main)
	
	func _to_string():
		return to_str()

class PhraseVerb:
	extends Phrase
	
	var adverb:PhraseAdverb
	var helping:PackedStringArray
	var modal:String
	var object:Phrase
	
	func to_str()->String:
		if helping:
			return " ".join(helping) + " ".join(main)
		if modal:
			return modal + " ".join(main)
		return " ".join(main)

class PhrasePronoun:
	extends Phrase
	
	var noun:ClauseNoun
	
	func to_str():
		if noun == null:
			return " ".join(main)
		else:
			return " ".join(main) + " " + noun.to_str()

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
	var conjunctiontype:CONJUNCTION_TYPE

class PhrasePreposition:
	extends Phrase
	var noun:ClauseNoun
	var emptypreposition:bool = true
	
	func to_str():
		if emptypreposition:
			return super.to_str()
		else:
			return super.to_str() + " " + noun.to_str()

enum CONJUNCTION_TYPE {
	Elements,
	Subordinating
}
