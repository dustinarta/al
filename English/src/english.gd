@tool
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

class UNDEFINED:
	var speech:String
	
	func _init(s:String):
		speech = s
	
	func _to_string():
		return "UNDEFINED: {" + speech + "}"

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
#		print("creating ", s, " ", o)
		self.type = my_o[0]
		self.each_type = my_o.slice(1)
#		print(self.type.size())
#		print(self.type)
#		print(self.each_type)
	
	func _to_string():
		var a = [type]
		a.append_array(each_type)
		var s:String = "SP: " + speech + " "
		s += En.speech_parse_string(a)
		return s
	
	func pick_type(type:float) -> Array:
		var i = self.type.find(type)
		print("pick type ", self.speech, self.each_type)
		if i != -1:
			return self.each_type[i].duplicate(true)
		else:
			return []

class Phrase:
	var speech:Array = []
	var speechtype:Array = []
	var type = null
	var count:int
	
	func _init():
		pass
	
	func is_empty() -> bool:
		if type == null:
			return true
		else:
			return false
	
	func steal(phrase:Phrase) -> void:
		var speech = phrase.speech
		var speechtype = phrase.speechtype
		for i in range(phrase.speech.size()):
			append(speech[i], speechtype[i].duplicate(true))
	
	func append(speech:String, speechtype:Array, index:int = -1) -> void:
		if index == -1:
			self.speech.append(speech)
			self.speechtype.append(speechtype)
		else:
			self.speech[index] = speech
			self.speechtype[index] = speechtype
		count += 1
	
	func last() -> Array:
		return [speech[-1], speechtype[-1]]
	
	func _next(collection:Array, index:int):
		if index >= collection.size():
			return null
		var s = collection[index]
		
		if s is SP:
			return s as SP
		elif s is SC:
			return s as SC
		else:
			return s
	
	func find_speech(speech:float, from := 0) -> int:
		if from == -1:
			return -1
		for i in range(from, count):
			if self.speechtype[i][0] == speech:
				return i
		return -1
	
	func find_speech_type(speech:float, speechtype:float, from := 0) -> int:
		var speechpos:Array
		var pos:int = from
		while true:
			pos = find_speech(speech, pos)
			if pos == -1:
				break
			speechpos.append(pos)
			pos += 1
#		print(typeof(speechpos[0]), typeof(speechtype), speechpos[0], speechtype)
		for i in range(speechpos.size()):
			if self.speechtype[speechpos[i]][1] == speechtype:
				return speechpos[i]
		return -1
	
	func find_speech_all(speech:float, from := 0) -> Array:
		var result = []
		if from == -1:
			return []
		for i in range(from, count):
			if self.speechtype[i][0] == speech:
				result.append(i)
		return result
	
	func find_speech_type_all(speech:float, speechtype:float, from := 0) -> Array:
		var speechpos:Array
		var result:Array = []
		var pos:int = from
		speechpos = find_speech_all(speech, pos)
#		print(typeof(speechpos[0]), typeof(speechtype), speechpos[0], speechtype)
		for i in range(speechpos.size()):
			if self.speechtype[speechpos[i]][1] == speechtype:
				result.append(speechpos[i])
		return result
	
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
		elif self.type == En.PHRASE_TYPE.Undefined:
			s += "Type: Undefined" 
			s += ", Count: " + str(self.count)
			s += ", Speech: [ "
			for i in range(self.speech.size()):
				var type = self.speechtype[i]
				s += self.speech[i] + ", "
			s = s.substr(0, s.length()-2)
#			s.erase(s.length()-1, " ".unicode_at(0))
#			s.erase(s.length()-1, ",".unicode_at(0))
			s += " ]"
		else:
			var key = En.PHRASE_TYPE.keys()
			s += "Type: " + str(key[int(self.type)])
			s += ", Count: " + str(self.count)
			s += ", Speech: [ " 
			print(speech, speech.size())
			for i in range(self.speech.size()):
				var type = self.speechtype[i]
#				print("type 0 ", type[0])
#				print("type 1 ", type[1])
				s += self.speech[i] + " (" + En.SPEECH_TYPE.keys()[type[0]] + ", " + En.speech_list[type[0]][type[1]] +"), "
#				s += str(self.speech[i].speech) + " "
			s = s.substr(0, s.length()-2)
#			s.erase(s.length()-1, " ".ord_at(0))
#			s.erase(s.length()-1, ",".ord_at(0))
			s += " ]"
		s += " }"
		return s
	
	func get_speech_line() -> String:
		return "".join(self.speech as PackedStringArray)
	
	func parse(sentence:Array, index:int, prev = null) -> int:
		var s = _next(sentence, index)
		print("working on == ", s)
		var typeis:float
		var result = -1
		
		if s is SP:
			var sp = s as SP
#			print(sp.speech, sp.each_type, sp.type)
			#speech type is preposition
			if sp.type.has(float(En.SPEECH_TYPE.Preposition)):
				result = _parse_preposition(sentence, index, prev)
			
			#speech type is adverb
			elif sp.type.has(float(En.SPEECH_TYPE.Adverb)):
				print("go to adverb")
				result = _parse_adverb(sentence, index, prev)
			
			#speech type is adjective
			elif sp.type.has(float(En.SPEECH_TYPE.Adjective)):
				result = _parse_adjective(sentence, index, prev)
			
			#speech type is conjunction
			elif sp.type.has(float(En.SPEECH_TYPE.Conjunction)):
				result = _parse_conjunction(sentence, index, prev)
			
			#speech type is pronoun
			elif sp.type.has(float(En.SPEECH_TYPE.Pronoun)):
				result = _parse_pronoun(sentence, index, prev)
			
			#speech type is noun
			elif sp.type.has(float(En.SPEECH_TYPE.Noun)):
				result = _parse_noun(sentence, index, prev)
			
			#speech type is verb
			elif sp.type.has(float(En.SPEECH_TYPE.Verb)):
				print("verb on ", sp.speech)
				result = _parse_verb(sentence, index, prev)
			
			else:
				print("Unexpected type ", sp.type)
			
			if result != -1:
				pass
			
		elif s is SC:
			pass
		elif s is UNDEFINED:
			var und = s as UNDEFINED
			type = En.PHRASE_TYPE.Undefined
			var running = true
			
			while running:
				print("index first, ", index)
				print("Undefined: ", und.speech)
				append(und.speech, [0, 0])
				index += 1
				print("index before, ", index)
				s = _next(sentence, index)
				print("index after, ", index)
				if s is UNDEFINED:
					und = s as UNDEFINED
					continue
				break
			
			result = index
			
		else:
			print("Full phrase")
		
		return result
	
	func _parse_noun(sentence:Array, index:int, prev_phrase) -> int:
		var sp = sentence[index] as SP
		type = En.PHRASE_TYPE.Noun
		var et = sp.pick_type(En.SPEECH_TYPE.Noun)
		var next
		
		if et.has(float(En.Noun.Proper)):
			append(sp.speech, [En.SPEECH_TYPE.Noun, En.Noun.Proper])
			
			var running = true
			while running:
				index += 1
				next = _next(sentence, index)
				if next is SP:
					var nextsp = next as SP
					if nextsp.type.has(float(En.SPEECH_TYPE.Noun)):
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Noun))
						if nextet.has(float(En.Noun.Proper)):
							append(nextsp.speech, [En.SPEECH_TYPE.Noun, En.Noun.Proper])
						continue
						break
					else:
						pass
#						print("invalid english \"", sentence[index-1].speech, " ", sentence[index].speech, "\"")
				break
			
		elif et.has(float(En.Noun.Common)):
			print("else noun")
			append(sp.speech, [En.SPEECH_TYPE.Noun, En.Noun.Common])
			index += 1
		else:
			return -1
		
		return index
	
	func _parse_pronoun(sentence:Array, index:int, prev_phrase) -> int:
		var sp = sentence[index] as SP
		type = En.PHRASE_TYPE.Pronoun
		var et = sp.pick_type(En.SPEECH_TYPE.Pronoun)
		var next
		var nextphrase:Phrase = Phrase.new()
		
		if et.has(float(En.Pronoun.Possesive)):
			append(sp.speech, [En.SPEECH_TYPE.Pronoun, En.Pronoun.Possesive])
			
			index += 1
			nextphrase.parse(sentence, index)
			if nextphrase.type == En.PHRASE_TYPE.Noun:
				#print(nextphrase)
				steal(nextphrase)
				return index + 1
			elif nextphrase.type == En.PHRASE_TYPE.Adjective:
				return index
			else:
				print("invalid english \"", sentence[index-1].speech, " ", sentence[index].speech, "\"")
		elif et.has(float(En.Pronoun.Demonstrative)):
			append(sp.speech, [En.SPEECH_TYPE.Pronoun, En.Pronoun.Demonstrative])
			
			index += 1
			next = _next(sentence, index)
			nextphrase.parse(sentence, index)
			if nextphrase.type == En.PHRASE_TYPE.Noun:
				#print(nextphrase)
				steal(nextphrase)
				return index + 1
			return index
		elif et.has(float(En.Pronoun.Relative)):
#			print("relative")
			append(sp.speech, [En.SPEECH_TYPE.Pronoun, En.Pronoun.Relative])
			type = En.PHRASE_TYPE.Relative
			return index + 1
		elif et.has(float(En.Pronoun.Owner)):
			append(sp.speech, [En.SPEECH_TYPE.Pronoun, En.Pronoun.Owner])
			return index + 1
		elif et.has(float(En.Pronoun.Personal)):
			if prev_phrase != null:
				append(sp.speech, [En.SPEECH_TYPE.Pronoun, En.Pronoun.Second])
				return index + 1
#			print("SP at ", index, " ", sentence[index].speech)
#			print("SP at ", index+1, " ", sentence[index+1].speech)
			append(sp.speech, [En.SPEECH_TYPE.Pronoun, En.Pronoun.Personal])
			return index + 1
		else:
			print("else pronoun")
			append(sp.speech, [En.SPEECH_TYPE.Pronoun, et[0]])
			return index + 1
		
		return -1
	
	func _parse_verb(sentence:Array, index:int, prev_phrase) -> int:
		var sp = sentence[index] as SP
		type = En.PHRASE_TYPE.Verb
		var et = sp.pick_type(En.SPEECH_TYPE.Verb)
		var next
		
		if et.has(float(En.Verb.Modal)):
			pass
		elif et.has(float(En.Verb.Auxiliary)):
			append(sp.speech, [En.SPEECH_TYPE.Verb, En.Verb.Auxiliary])
			index += 1
			next = _next(sentence, index)
			if next is SP:
				var nextsp = next as SP
				
				if nextsp.type.has(float(En.SPEECH_TYPE.Verb)):
					var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Verb))
					print(nextet)
					append(nextsp.speech, [En.SPEECH_TYPE.Verb, nextet[0]])
					return index + 1
					
			return index
		else:
			print("verb success on ", sp.speech)
			append(sp.speech, [En.SPEECH_TYPE.Verb, sp.type[0]])
			return index + 1
		print("verb exit")
		return -1
	
	func _parse_adjective(sentence:Array, index:int, prev_phrase) -> int:
		var sp = sentence[index] as SP
		type = En.PHRASE_TYPE.Adjective
		var et = sp.pick_type(En.SPEECH_TYPE.Adjective)
		var next
		# typeis = En.PHRASE_TYPE.Noun
		
		if et.has(float(En.Adjective.Article)):
			type = En.PHRASE_TYPE.Noun
			append(sp.speech, [En.SPEECH_TYPE.Adjective, En.Adjective.Article])
			
			var running = true
			while running:
				index += 1
				next = _next(sentence, index)
				if next is SP:
					var nextsp = next as SP
					
					if nextsp.type.has(float(En.SPEECH_TYPE.Adjective)):
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Adjective))
						append(nextsp.speech, [En.SPEECH_TYPE.Adjective, nextet[0]])
						continue
					
					elif nextsp.type.has(float(En.SPEECH_TYPE.Adverb)):
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Adverb))
						if nextet.has(float(En.Adverb.Modify)):
							append(nextsp.speech, [En.SPEECH_TYPE.Adverb, En.Adverb.Modify])
							continue
						else:
							print("invalid english \"", sentence[index-1].speech, " ", sentence[index].speech, "\"")
					
					elif nextsp.type.has(float(En.SPEECH_TYPE.Noun)):
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Noun))
						append(nextsp.speech, [En.SPEECH_TYPE.Noun, nextet[0]])
						continue
						
					else:
						break
					
					print("invalid english \"", sentence[index-1].speech, " ", sentence[index].speech, "\"")
				else:
					break
			return index
		else:
			type = En.PHRASE_TYPE.Adjective
			append(sp.speech, [En.SPEECH_TYPE.Adjective, et[0]])
			
			var running = true
			while running:
				index += 1
				next = _next(sentence, index)
				if next is SP:
					var nextsp = next as SP
					
					if nextsp.type.has(float(En.SPEECH_TYPE.Adjective)):
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Adjective))
						if nextet.has(float(En.Adjective.Article)):
							print("invalid english \"", sentence[index-1].speech, " ", sentence[index].speech, "\"")
							return -1
						append(nextsp.speech, [En.SPEECH_TYPE.Adjective, nextet[0]])
						continue
					elif nextsp.type.has(float(En.SPEECH_TYPE.Noun)):
						type = En.PHRASE_TYPE.Noun
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Noun))
						append(nextsp.speech, [En.SPEECH_TYPE.Noun, nextet[0]])
						return index
				else:
					running = false
			return index
		
		return -1
	
	func _parse_adverb(sentence:Array, index:int, prev_phrase) -> int:
		var sp = sentence[index] as SP
		type = En.PHRASE_TYPE.Adverb
		var et = sp.pick_type(En.SPEECH_TYPE.Adverb)
		var next
		var afterverb = false
		
		#continue the previous adverb
		if prev_phrase != null:
			if prev_phrase.type == En.PHRASE_TYPE.Adverb:
				prev_phrase.append(sp.speech, [En.SPEECH_TYPE.Adverb, et[0]])
				type = null
				return index + 1
		
		#checking if its after a verb
		if index > 0:
			var prev = _next(sentence, index-1)
			if prev is SP:
				var prevsp = prev as SP
				
				if prevsp.type.has(float(En.SPEECH_TYPE.Verb)):
					afterverb = true
		
		if et.has(float(En.Adverb.Modify)):
			
			append(sp.speech, [En.SPEECH_TYPE.Adverb, En.Adverb.Modify])
			
			var running = true
			while running:
				index += 1
				next = _next(sentence, index)
				if next is SP:
					var nextsp = next as SP
					
					if nextsp.type.has(float(En.SPEECH_TYPE.Adverb)):
						if type != En.PHRASE_TYPE.Adverb:
							print("invalid english \"", sentence[index-1].speech, " ", sentence[index].speech, "\"")
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Adverb))
						append(nextsp.speech, [En.SPEECH_TYPE.Adverb, nextet[0]])
						continue
					elif nextsp.type.has(float(En.SPEECH_TYPE.Adjective)):
						type = En.PHRASE_TYPE.Adjective
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Adjective))
						append(nextsp.speech, [En.SPEECH_TYPE.Adjective, nextet[0]])
						continue
					elif nextsp.type.has(float(En.SPEECH_TYPE.Noun)):
						if type != En.PHRASE_TYPE.Adjective:
							print("invalid english \"", sentence[index-1].speech, " ", sentence[index].speech, "\"")
						type = En.PHRASE_TYPE.Noun
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Noun))
						append(nextsp.speech, [En.SPEECH_TYPE.Noun, nextet[0]])
						continue
					else:
						return index
		elif et.has(float(En.Adverb.Degree)) or et.has(float(En.Adverb.Manner)):
#			print(self.speechtype)
			index += 1
			next = _next(sentence, index)
			append(sp.speech, [En.SPEECH_TYPE.Adverb, et[0]])
#			print(self.speechtype)
#			print(self)
			if next is SP:
				var nextsp = next as SP
				
				if nextsp.type.has(float(En.SPEECH_TYPE.Verb)):
					type = En.PHRASE_TYPE.Verb
					speechtype[speechtype.size()-1][1] = En.Adverb.Degree
					var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Verb))
					append(nextsp.speech, [En.SPEECH_TYPE.Verb, nextet[0]])
					return index + 1
			return index
		else:
			print("else adverb")
			append(sp.speech, [En.SPEECH_TYPE.Adverb, et[0]])
			var running = true
			while running:
				index += 1
				next = _next(sentence, index)
				if next is SP:
					var nextsp = next as SP
					
					if nextsp.type.has(float(En.SPEECH_TYPE.Verb)):
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Verb))
						append(nextsp.speech, [En.SPEECH_TYPE.Verb, nextet[0]])
						type = En.PHRASE_TYPE.Verb
						return index + 1
					elif nextsp.type.has(float(En.SPEECH_TYPE.Adverb)):
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Adverb))
						append(nextsp.speech, [En.SPEECH_TYPE.Adverb, nextet[0]])
						continue
					elif nextsp.type.has(float(En.SPEECH_TYPE.Adjective)):
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Adjective))
						append(nextsp.speech, [En.SPEECH_TYPE.Adjective, nextet[0]])
						continue
					elif nextsp.type.has(float(En.SPEECH_TYPE.Noun)):
						var nextet = nextsp.pick_type(float(En.SPEECH_TYPE.Noun))
						append(nextsp.speech, [En.SPEECH_TYPE.Noun, nextet[0]])
						continue
					else:
						break
					
					print("invalid english \"", sentence[index-1].speech, " ", sentence[index].speech, "\"")
				else:
					break
			return index
			
		return -1
	
	func _parse_conjunction(sentence:Array, index:int, prev_phrase) -> int:
		var sp = sentence[index] as SP
		type = En.PHRASE_TYPE.Conjunctive
		var et = sp.pick_type(En.SPEECH_TYPE.Conjunction)
		
		append(sp.speech, [En.SPEECH_TYPE.Conjunction, et[0]])
		print("after conjunctive is ", sentence[index + 1].speech)
		return index + 1
		
		return -1
	
	func _parse_preposition(sentence:Array, index:int, prev_phrase) -> int:
		var sp = sentence[index] as SP
		type = En.PHRASE_TYPE.Prepositional
		var et = sp.pick_type(En.SPEECH_TYPE.Preposition)
		var next
		var nextphrase = Phrase.new()
		
		#special case for infinitive
		if sp.speech == "to":
			var newindex = nextphrase.parse(sentence, index+1, null)
			if nextphrase.type == En.PHRASE_TYPE.Verb:
				append(sp.speech, [En.SPEECH_TYPE.Preposition, En.Preposition.Direction])
				print(nextphrase)
				steal(nextphrase)
				type = En.PHRASE_TYPE.Infinitive
				return newindex
		
		if et.has(float(En.Preposition.Specification)):
			append(sp.speech, [En.SPEECH_TYPE.Preposition, En.Preposition.Specification])
			
			return index + 1
		#elif et.has(float(En.Pronoun.Owner)):
		#	append(sp.speech, [En.SPEECH_TYPE.Pronoun, En.Pronoun.Owner])
		#	return index + 1
		else:
			print("else preposition")
			append(sp.speech, [En.SPEECH_TYPE.Preposition, et[0]])
			return index + 1
		
		return -1

class Collection:
	var elements:Array
	var count:int
	
	func _setsize(value:int):
		printerr("Size are not allowed to set!")
		print_stack()
	
	func _init(_phrases:Array):
		
#		for i in range(_phrases.size()):
#			if _phrases[i] is Phrase:
#				continue
#			print("wrong data type ", _phrases[i])
#			break
		elements = _phrases.duplicate(true)
		count = _phrases.size()
	
	func _to_string():
		var s = "Collection: { Count = " + str(count)
		s += ", Phrases = "
		
		if count != 0:
			s += str(elements)
		s += " }"
		return s
	
	func print()->String:
		var str:String
		for i in range(count):
			if elements[i] is Phrase:
				for j in range(elements[i].speech.size()):
					str += elements[i].speech[j] + " "
				str = str.substr(0, str.length()-1)
			elif elements[i] is SC:
				str = str.substr(0, str.length()-1)
				str += elements[i].c
			str += " "
		str = str.substr(0, str.length()-1)
		return str
	
#	func find_type(type:int, from:int = -1):
#
#		for i in range(count):
#			if (phrases[i] as Phrase).type == type:
#				return i
#
#		return -1

var path = "res://English/dataset-key2.json"

var _has_init = false
func init(path:String):
	if _has_init == true:
		return
	
	load_data(path)
	
	_has_init = true

func read(sentence:String) -> Collection:
	var each = parse(sentence.to_lower())
	var results:Array = []
	results.append("\"" + str(sentence) + "\"")
	results.append(each)
	results.append(find_speech(each))
	
	if report_null([each, results[2]]):
		pass
	
	results.append(_phraser(results[-1]))
	
	return Collection.new(results[-1].duplicate(true))

func _phraser(sentence) -> Array:
	var result:Array = []
	var i = 0
	var limit = sentence.size()
	
	print("phrasing ", sentence)
	
	var phrase
	
	var counterindex = 0
	var counterlimit = 20
	
	while i != -1:
		counterindex += 1
		
#		print("before")
		if sentence[i] is SC:
			result.append(sentence[i])
			i += 1
			continue
		phrase = Phrase.new()
		#print(sentence, " ", i)
		i = phrase.parse(sentence, i, result.back() if result.size() else null)
#		print("after")
		print("i is, ", i)
		if counterindex >= counterlimit:
			printerr("Break at loop bug! in counter ", counterlimit)
			break
		if phrase.is_empty():
			break
		result.append(phrase)
		
		if i >= limit:
			break
	
	return result

func find_speech(words:Array) -> Array:
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
			result[i] = UNDEFINED.new(key)
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

func report_null(result) -> bool:
	var words = result[0] as Array
	var type = result[1] as Array
	var size = words.size()
	
	var missing:Array = []
	var pos:int = 0
	for i in range(size):
		if type[i] is UNDEFINED:
			missing.append(type[i].speech)
			
	if missing.size() == 0:
		print("No missing")
		return false
	else:
		print("Missing: " + str(missing))
		return true

func add_data(speech:String, type1:float, type2:float):
	print("adding english data ", speech)
	if !data.has(speech):
		data[speech] = [[type1], [type2]]
	else:
		var pos = data[speech][0].find(type1)
		if pos != -1:
			data[speech][pos + 1].append(type2)
		else:
			data[speech][0].append(type1)
			data[speech].append([type2])

func save_data():
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))
	f.close()

func load_data(path):
	var f = FileAccess.open(path, FileAccess.READ)
	var s = f.get_as_text()
	f.close()
	
	data = JSON.parse_string(s) as Dictionary

func _to_string():
	var result = "English Singleton : {\n"
	result += "\tword count = " + str(data.size())
	result += "\n}"
	return result

func _phraser_find(sentence:Array, speech:float) -> Array:
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

func _phraser_find_type(sentence:Array, speech:float, type:float) -> Array:
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
