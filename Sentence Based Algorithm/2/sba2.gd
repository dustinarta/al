extends Node
class_name SBA2

enum WORD_TYPE {
	NOUN_PROPER,
	NOUN_COMMON,
	
	PRONOUN,
	PRONOUN_DEMONSTRATIVE,
	PRONOUN_POSSESSIVE,
	
	ADJECTIVE_AS_NOUN,
	ADJECTIVE_TO_NOUN,
	
	VERB_MAIN,
	VERB_MODAL,
	VERB_HELPING,
	VERB_PARTICIPLE,
	
	ADVERB_TO_ADJECTIVE,
	ADVERB_TO_ADVERB,
	ADVERB_TO_VERB,
	ADVERB_TO_SENTENCE,
	
	CONJUNCTION_COORDINATING,
	CONJUNCTION_SUBORDINATING,
	
	PREPOSITION_SPESIFICATION,
	PREPOSITION_INSTRUMENT,
	PREPOSITION_TO_PHRASAL_VERB,
	
	INFINITIVE
}

enum SENTENCE_TYPE {
	PHRASE,
	SIMPLE,
	INTERROGATIVE,
	CONJUNCTIVE
}

var memory:Dictionary = {
	
}

func _init():
	pass
	pass

class SentenceObject:
	var type:SENTENCE_TYPE
	
	var subject:Element
	var verb:Element
	var object:Element
	var prepositions:Array[Element]
	
	var conjunction:Element
	var conjunctionTo:SentenceObject
	
	func init(packed:English.Collection):
		
		for s in packed.elements:
			if s is English.Phrase:
				var phrase = s as English.Phrase
				match phrase.type:
					En.PHRASE_TYPE.Noun:
						var element:Element
						var nouns = phrase.find_speech_type_all(En.SPEECH_TYPE.Noun, En.Noun.Proper)
						if nouns.is_empty():
							nouns = phrase.find_speech_type_all(En.SPEECH_TYPE.Noun, En.Noun.Common)
						for noun in nouns:
							element.name += phrase.speech[noun] + " "
						element.name = element.name.substr(0, -2)
						if subject == null:
							pass
			elif s is English.SC:
				pass

class Element:
	var name:String
	
