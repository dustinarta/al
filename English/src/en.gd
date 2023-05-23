@tool
extends Node

enum SPEECH_TYPE {
	Noun = 0,
	Pronoun = 1,
	Verb = 2,
	Adjective = 3,
	Adverb = 4,
	Conjunction = 5,
	Preposition = 6,
	Interjection = 7
}

enum Noun {
	Common = 0,
	Proper = 1
}

enum Pronoun {
	Personal,
	Second,
	Possesive,
	Owner,
	Intensive,
	Demonstrative,
	Indefinite,
	Relative
}

enum Verb {
	Auxiliary = 0,
	Modal = 1,
	Action = 2,
	State = 3
}

enum Adjective {
	Comparative,
	Superlative,
	Descriptive,
	Determiner ,
	Article,
	Order
}

enum Adverb {
	Place,
	Time,
	Frequency,
	Manner,
	Degree,
	Modify,
	Point,
	Conjunctive,
	Order
}

enum Conjunction {
	Coordinating,
	Subordinating,
	Correlative
}

enum Preposition {
	Specification,
	Instrument,
	Direction
}

enum Interjection {
	Slang
}

enum PHRASE_TYPE {
	Undefined,
	Noun,
	Relative,
	Pronoun,
	Verb,
	Adjective,
	Adverb,
	Conjunctive,
	Prepositional,
	Infinitive,
	Gerund
}

enum CLAUSE_TYPE {
	none,
	Independent,
	Dependent,
	Question,
	Noun,
	Adjective,
	Preposition
}

var speech_list = [Noun.keys(), Pronoun.keys(), Verb.keys(), Adjective.keys(), Adverb.keys(), Conjunction.keys(), Preposition.keys(), Interjection.keys()]

static func speech_parse_string(current_type_int) -> String:
	var speech_list = [Noun.keys(), Pronoun.keys(), Verb.keys(), Adjective.keys(), Adverb.keys(), Conjunction.keys(), Preposition.keys(), Interjection.keys()]
	var speech_type = SPEECH_TYPE.keys()
	#print(current_type_int)
	var s:String = ""
	var types = current_type_int[0]
	
	s += "{"
	for i in range(types.size()):
		s += speech_type[types[i]]
		var each_type = current_type_int[i + 1]
		var etl = each_type.size()
		for j in range(etl):
			if j == 0:
				s += "("
			else:
				s += ", "
			s += str(speech_list[types[i]][each_type[j]])
			if j == etl - 1:
				s += ")"
		if i != types.size()-1:
			s += ", "
	s += "}"
	return s

enum CATEGORY {
	SPEECH,
	PHRASE,
	CLAUSE,
	SENTENCE
}
