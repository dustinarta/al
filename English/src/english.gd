tool
extends Node

"""
This is a script for singleton of "English"
"""


var speech_list = [
	En.Noun.keys(), 
	En.Pronoun.keys(), 
	En.Verb.keys(), 
	En.Adjective.keys(), 
	En.Adverb.keys(), 
	En.Conjunction.keys(), 
	En.Preposition.keys(), 
	En.Interjection.keys()
	]

var data:Dictionary = {}

func read(sentence:String)->Array:
	var each = parse(sentence.to_lower())
	var results:Array = []
	results.append("\"" + str(sentence) + "\"")
	results.append(each)
	results.append(find_speech(each))
	
	print(_phraser(results[-1]))
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
		if o == []:
			print("Undefined \"" + self.speech + "\"")
			return
		var my_o = o.duplicate(true)
		self.type = my_o[0]
		self.each_type = my_o.slice(1, self.type.size())
	
	func _to_string():
		var a = [type]
		a.append_array(each_type)
		var s:String = "SP: " + speech + " "
		s += En.speech_parse_string(a)
		return s
	
	func pick_type(type:float) -> Array:
		var i = self.type.find(type)
		
		if i != -1:
			return self.each_type[i].duplicate(true)
		else:
			return []

class Phrase:
	var speech:Array = []
	var speechtype:Array = []
	var type = null
	
	func _init():
		pass
	
	func is_empty() -> bool:
		if type == null:
			return true
		else:
			return false
	
	
	func parse(sentence:Array, index:int):
		var s = _next(sentence, index)
		var typeis:float
		
		if s is SP:
			var sp = s as SP
			
			
			print(sp.type)
			
			#speech type is adjective
			if sp.type.has(float(En.SPEECH_TYPE.Adjective)):
				return _parse_adjective(sentence, index)
			
			#speech type is pronoun
			if sp.type.has(float(En.SPEECH_TYPE.Pronoun)):
				return _parse_pronoun(sentence, index)
			
			#speech type is verb
			if sp.type.has(float(En.SPEECH_TYPE.Verb)):
				return _parse_verb(sentence, index)
			
		elif s is SC:
			pass
			
		
		return -1
	
	func _parse_pronoun(sentence:Array, index:int):
		var sp = sentence[index] as SP
		var typeis = En.PHRASE_TYPE.Noun
		var et = sp.pick_type(En.SPEECH_TYPE.Pronoun)
		var next
		
		if et.has(float(En.Pronoun.Possesive)):
			self.type = typeis
			speech.append(sp.speech)
			speechtype.append([En.SPEECH_TYPE.Pronoun, En.Pronoun.Possesive])
			index += 1
			next = _next(sentence, index)
			
			if next is SP:
				var nextsp = next as SP
				print("here")
				if nextsp.type.has(float(En.SPEECH_TYPE.Noun)):
					var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Noun))
					speech.append(nextsp.speech)
					speechtype.append([En.SPEECH_TYPE.Noun, nextet[0]])
					return index + 1
				else:
					print("invalid english")
		
		if et.has(float(En.Pronoun.Owner)):
			self.type = typeis
			if speech.size() > 0:
				speechtype[speech.size()-1][1] = En.Pronoun.Owner
				return index
			else:
				speech.append(sp)
				return index + 1
		
		else:
			speech.append(sp)
			return index + 1
	
	func _parse_verb(sentence:Array, index:int):
		var sp = sentence[index] as SP
		var typeis = En.PHRASE_TYPE.Verb
		var et = sp.pick_type(En.SPEECH_TYPE.Verb)
		var next
		
		if et.has(float(En.Verb.Modal)):
			pass
		elif et.has(float(En.Verb.Auxiliary)):
			self.type = typeis
			speech.append(sp.speech)
			speechtype.append([En.SPEECH_TYPE.Verb, En.Verb.Auxiliary])
			index += 1
			next = _next(sentence, index)
			if next is SP:
				var nextsp = next as SP
				
				if nextsp.type.has(float(En.SPEECH_TYPE.Verb)):
					var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Verb))
					speech.append(nextsp.speech)
					speechtype.append([En.SPEECH_TYPE.Verb, nextet[0]])
					return index + 1
				else:
					return index
		else:
			self.type = typeis
			speech.append(sp)
			return index + 1
	
	func _parse_adjective(sentence:Array, index:int):
		var sp = sentence[index] as SP
		var typeis = null
		var et = sp.pick_type(En.SPEECH_TYPE.Adjective)
		var next
		# typeis = En.PHRASE_TYPE.Noun
		
		if et.has(float(En.Adjective.Article)):
			typeis = En.PHRASE_TYPE.Noun
			type = typeis
			speech.append(sp.speech)
			speechtype.append([En.SPEECH_TYPE.Adjective, En.Adjective.Article])
			index += 1
			next = _next(sentence, index)
			if next is SP:
				var nextsp = next as SP
				
				if nextsp.type.has(float(En.SPEECH_TYPE.Noun)):
					var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Noun))
					speech.append(nextsp.speech)
					speechtype.append([En.SPEECH_TYPE.Noun, nextet.type[0]])
					return index + 1
				
			else:
				print("invalid english")
	
	func _next(sentence:Array, index:int):
		if sentence.size() <= index:
			return null
		var s = sentence[index]
		
		if s is SP:
			return s as SP
		elif s is SC:
			return s as SC
		else:
			return s
	
	func _find(sentence:Array, speech:float, limit := [])->Array:
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
	
	func _find_type(sentence:Array, speech:float, type:float, limit := [])->Array:
		var result:Array = []
		var speechs = _find(sentence, speech)
		var length = speechs.size()
		#each speech index
		for i in range(length):
			var index = speechs[i]
			var sp = sentence[index] as SP
			#each type of speech index
			for j in range(sp.type.size()):
				if sp.each_type[j].has(type):
					result.append(index)
					break
		
		return result
		
	func _to_string() -> String:
		var s:String = "Phrase = { "
		if self.type == null:
			s += "NULL"
		else:
			var key = En.PHRASE_TYPE.keys()
			s += "Type: " + str(key[int(self.type)])
			s += ", Speech: [ " 
			for i in range(self.speech.size()):
				var type = self.speechtype[i]
				s += self.speech[i] + " (" + En.SPEECH_TYPE.keys()[type[0]] + ", " + En.speech_list[type[0]][type[1]] +"), "
#				s += str(self.speech[i].speech) + " "
			s.erase(s.length()-1, " ".ord_at(0))
			s.erase(s.length()-1, ",".ord_at(0))
			s += " ]"
		s += " }"
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
		else:
			result[i] = SP.new(key, [])
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

func _to_string():
	var result = "English Singleton : {\n"
	result += "\tword count = " + str(data.size())
	result += "\n}"
	return result

func _phraser(sentence)->Array:
	var result:Array = []
	var i = 0
	
	var phrase = Phrase.new()
	i = phrase.parse(sentence, i)
	result.append(phrase)
	
	while i != -1:
		phrase = Phrase.new()
		i = phrase.parse(sentence, i)
		if phrase.is_empty():
			break
		result.append(phrase)
	
	return result

func _phraser_find(sentence:Array, speech:float)->Array:
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

func _phraser_find_type(sentence:Array, speech:float, type:float)->Array:
	var result:Array = []
	var speechs = _phraser_find(sentence, speech)
	var length = speechs.size()
	#each speech index
	for i in range(length):
		var index = speechs[i]
		var sp = sentence[index] as SP
		#each type of speech index
		for j in range(sp.type.size()):
			if sp.each_type[j].has(type):
				result.append(index)
				break
	
	return result

func _find_auxilary(sentence:Array)->Array:
	var result:Array = _phraser_find_type(sentence, float(English.SPEECH_TYPE.Verb), float(English.Verb.Auxiliary))
	
	return result

