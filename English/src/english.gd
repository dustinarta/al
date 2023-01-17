tool
extends Node

"""
This is a script for singleton of "English"
"""


var speech_list = [Noun.keys(), Pronoun.keys(), Verb.keys(), Adjective.keys(), Adverb.keys(), Conjunction.keys(), Preposition.keys(), Interjection.keys()]
var data :Dictionary = {}

func read(sentence:String)->Array:
	var each = parse(sentence.to_lower())
	var results:Array = []
	results.append("\"" + str(sentence) + "\"")
	results.append(each)
	results.append(find_speech(each))
	
	_pharser(results[-1])
#	report_null([each, results[1]])
	
	return results

class SC:
	var c:String
	
	func _init(c:String = ""):
		self.c = c
	
	func _to_string():
		return "SC: {" + c + "}"

class SP:
	var speech:String
	
	var type:Array
	var each_type:Array
	
	func _init(s:String, o:Array):
		self.speech = s
		var my_o = o.duplicate(true)
		self.type = my_o[0]
		if self.type.size() != 0:
			self.each_type = my_o.slice(1, self.type.size())
		else:
			print("Undefined \"" + self.speech + "\"")
	
	func _to_string():
		var a = [type]
		a.append_array(each_type)
		var s:String = "SP: " + speech + " "
		s += En.speech_parse_string(a)
		return s

func init(path = "res://English/dataset-key2.json"):
	var f = File.new()
	f.open(path, File.READ)
	var s = f.get_as_text()
	data = JSON.parse(s).result as Dictionary
	
	f.close()

func find_speech(words:Array)->Array:
	var result = []
	result.resize(words.size())
	
	for i in range(words.size()):
		var key = words[i]
		if key is SC:
			result[i] = key
			continue
		if data.has(key):
			result[i] = SP.new(key, data[key])
	#		result[i] = data[key]

	return result

func parse(sentence:String):
	var each = sentence.split(" ")
	var res:Array = []
	
	for s in each:
		var fc:String #first index char
		var lc:String #last index char
		var f:int #first index
		var l:int #last index
		var size = s.length()
		
		for j in range(size):
			fc = s[j]
			match(fc):
				"(", "[", "{", "-", "\"", "'":
					res.append(SC.new(fc))
				_:
					f = j
					break
		
		var back:Array = []
		for j in range(size-1, 0, -1):
			lc = s[j]
			match(lc):
				"/", ")", "]", "}", "-", "\"", "'", ",", ".", ";", ":":
					back.append(SC.new(lc))
				_:
					l = j
					break
			
		res.append(s.substr(f, l-f+1))
		res.append_array(back)
		
	return res

func report_null(result)->void:
	var words = result[0] as Array
	var type = result[1] as Array
	var size = words.size()
	
	var missing:Array = []
	var pos:int = 0
	while(pos < size):
		pos = type.find(null, pos)
		if pos == -1:
			break
		else:
			missing.push_back(words[pos])
			pos += 1
			
	if missing.size() == 0:
		print("No missing")
	else:
		print("Missing: " + str(missing))

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

func _to_string():
	var result = "English Singleton : {\n"
	result += "\tword count = " + str(data.size())
	result += "\n}"
	return result
	

func _pharser(sentence)->Array:
	var result:Array = []
	var aux_pos = _find_auxilary(sentence)
	print("Auxilary at " + str(aux_pos))
	return result

func _pharser_find(sentence:Array, speech:float)->Array:
	var result:Array = []
	var length = sentence.size()
	for i in range(length):
		var s = sentence[i]
		if s is SC:
			continue
		elif s is SP:
			var sp = s as SP
			var pos = sp.type.find(speech)
			if pos != -1:
				result.append(i)
		else:
			print("Not Written")
	
	return result

func _pharser_find_type(sentence:Array, speech:float, type:float)->Array:
	var result:Array = []
	var speechs = _pharser_find(sentence, speech)
	var length = speechs.size()
	for i in range(length):
		var index = speechs[i]
		var sp = sentence[index] as SP
		if sp.each_type.has(type):
			result.append(index)
	
	return result

func _find_auxilary(sentence:Array)->Array:
	var result:Array = _pharser_find_type(sentence, SPEECH_TYPE.Verb, Verb.Auxiliary)
	# var verbs = _pharser_find(sentence, SPEECH_TYPE.Verb)
	# var length = verbs.size()
	# for i in range(length):
		
	
	return result

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
	Common
	Proper
	Idea
	Collective
}

enum Pronoun {
	Relative
	Indefinite
	Demonstrative
	Possesive
	Intensive
}

enum Verb {
	Auxiliary = 0
	Modal = 1
	Action = 2
	State = 3
}

enum Adjective {
	Comparative
	Superlative
	Descriptive
	Determiner 
	Article
}

enum Adverb {
	Frequency
	Manner
	Degree
	Order
}

enum Conjunction {
	Coordinating 
	Subordinating
	Correlative
}

enum Preposition {
	Location
	Time
	Direction 
	Instrument
}

enum Interjection {
	Slang
}