@tool
extends Node

var data
var Variable:Array
var Classes:Dictionary

var path = "res://Sentence Based Algorithm/memory.json"

var dont_execute = false
var _has_init = false
func init(path:String = self.path):
	loopcounter = 0
	if _has_init == true:
		return
	
	English.init(English.path)
	print(English._has_init)
	
	var f = FileAccess.open(path, FileAccess.READ)
	data = JSON.parse_string(f.get_as_text()) as Dictionary
	f.close()
	
	Variable = data["variable"]
	Classes = data["class"]
	
	sentences.clear()
	dont_execute = false
	_has_init = true

func save(path:String = ""):
	if path == "":
		path = self.path
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify(data, "\t"))
	f.close()

func add_class(varclass:Dictionary, overwrite:bool = false):
	if varclass.has("_n") and varclass.has("_p") and varclass.has("_v"):
		var nameclass = varclass["_n"]
		if Classes.has(nameclass):
			if overwrite:
				Classes[nameclass] = varclass
			else:
				return FAILED
		else:
			Classes[nameclass] = varclass
		return OK
	return FAILED

var sentences:Array[Clause] = []

func push(s:String, pos:int = 0):
	var coll = English.read(s)
	var clause:Clause = parse_clause(coll, pos)
	var result
	
	sentences.append(clause)
	#print(clause)
	if not dont_execute:
		result = run(clause)
	else:
		result = "ok"
	print(coll.print() + " : ", result)
	print(clause.last_entity().identifier, " ", clause.last_entity().data)
	#English.save_data()
	#self.save(path)

var loopcounter:int = 0

func parse_clause(coll:English.Collection, pos:int = 0, once:bool = false):
	var limit:int = coll.count
	var phrase:English.Phrase
	var clause:Clause = Clause.new()
	var result
	
	print("first, loop counter is ", loopcounter)
	loopcounter += 1
	if loopcounter > 10:
		printerr("Loop error ", loopcounter, " ", loopcounter > 5)
		return null
	else:
#		print("loop counter ", loopcounter)
		pass
	
	print(coll)
	
	var conjunction:String = ""
	
	var running = true
	var pos_last:int = pos
	while running:
		var next = coll.elements[pos]
		if next is English.SC:
			var nextsc:English.SC = next
			print("SC is ", nextsc.c)
			if conjunction != "":
				print("pushing next clause conjunctive ", conjunction)
				pos += 1
				clause.end = nextsc.c
				clause.nextclause = parse_clause(coll, pos)
				clause.type = En.CLAUSE_TYPE.Dependent
				break
			else:
				print("conjunction is ", conjunction)
				print("SC is ", nextsc.c)
				printerr("uncatched code 74")
		
		phrase = next
		
		if phrase.type == En.PHRASE_TYPE.Noun or phrase.type == En.PHRASE_TYPE.Pronoun:
			if clause.task.is_empty():
				pos = clause.subject.init(coll.elements, pos, clause)
				if clause.type == En.CLAUSE_TYPE.none:
					clause.type = En.CLAUSE_TYPE.Noun
				print("after subject ", clause.string)
			else:
				pos = clause.task.object.init(coll.elements, pos, clause)
#				var entity = Entity.new()
#				pos = entity.init(coll.elements, pos)
#				clause.object.append(entity)
			clause.composition.append(En.PHRASE_TYPE.Noun)
			if pos == null:
				printerr("error catched in noun")
				return null
		elif phrase.type == En.PHRASE_TYPE.Relative:
			clause.relative = phrase.speech[0]
			clause.string += phrase.speech[0] + " "
			pos += 1
		elif phrase.type == En.PHRASE_TYPE.Verb:
			if not clause.task.is_empty():
				printerr("Invalid verb!")
				print(clause.task)
				print(phrase)
				return null
			pos = clause.task.init(coll.elements, pos, clause)
			if clause.type == En.CLAUSE_TYPE.Noun:
				clause.type = En.CLAUSE_TYPE.Independent
			clause.composition.append(En.PHRASE_TYPE.Verb)
		elif phrase.type == En.PHRASE_TYPE.Adjective:
			pass
		elif phrase.type == En.PHRASE_TYPE.Adverb:
			pass
		elif phrase.type == En.PHRASE_TYPE.Conjunctive:
			if conjunction != "" and not once:
				print("pushing next clause conjunctive ", conjunction)
				clause.nextclause = parse_clause(coll, pos)
				break
			
			conjunction = phrase.speech[0]
			print("conjunctive here at ", conjunction)
			clause.conjunction = conjunction
			clause.type = En.CLAUSE_TYPE.Dependent
			clause.string += conjunction + " "
			pos += 1
			clause.composition.append(En.PHRASE_TYPE.Conjunctive)
		elif phrase.type == En.PHRASE_TYPE.Undefined:
			if clause.task.count == 0:
				pos = clause.subject.init(coll.elements, pos, clause)
				clause.type = En.CLAUSE_TYPE.Noun
				print("after undefined ", clause.string)
			else:
				printerr("Undefined object at ", pos)
				print(clause.task)
			clause.composition.append(En.PHRASE_TYPE.Noun)
		elif phrase.type == En.PHRASE_TYPE.Prepositional:
			var prep:Preposition = Preposition.new()
			pos = prep.init(coll.elements, pos, clause)
			clause.prespositions.append(prep)
			clause.composition.append(En.PHRASE_TYPE.Prepositional)
		else:
			printerr("Unwritten phrase type \"", En.PHRASE_TYPE.keys()[phrase.type], "\"")
#			pos += 1
		
#		clause.string += " ".join(phrase.speech as PackedStringArray) + " "
		
		if pos == pos_last:
			printerr("Loop detected! at ", pos)
			return null
		
		if pos == -1:
			printerr("Error catched!")
			print("Previous index: ", pos_last)
			return null
		
		pos_last = pos
		if pos >= limit:
			running = false
	
	clause.string = clause.string.substr(0, clause.string.length()-1)
	
	return clause

func run(clause:Clause, use_conjunction = true):
#	print("top execute", clause)
	if clause.has_relative():
		return execute_relative(clause)
	
	var state:Clause.State = clause.state
	
	var subject:Noun = clause.subject
	var do:Task = clause.task
	var object:Noun = clause.task.object
	var conjunction = clause.conjunction
	var answer:String = "ok"
#	print(conjunction)
	if use_conjunction and conjunction:
		var nextclause
		if conjunction == "if":
			var result = clause_check(clause)
			print("result of ", clause.string, " is ", result)
			nextclause = clause.nextclause
			if nextclause == null:
				print("next clause is null")
				return answer
			if result == "yes" and (nextclause.conjunction == "then" or clause.end == ","):
				print("entering yes with result ", result)
				result = run(nextclause, false)
				return "yeah"
			
			print(result)
			answer = result
		return answer
	
	if clause.nextclause != null:
		var nextclause = clause.nextclause
		
	
	if not (clause.type == En.CLAUSE_TYPE.Independent or clause.type == En.CLAUSE_TYPE.Dependent):
		printerr("Unwritten code 230")
		return ":'("
	
	if do.count == 1:
		if do.has("is") or do.has("are"):
			
			var ob:Entity = object.entities[0]
			if state == Clause.State.TELL:
				clause_assign(clause)
			elif state == Clause.State.ASK:
				clause_check(clause)
#			for j in range(subject.count):
#				var sub = subject.entities[j] as Entity
#
#				if sub.type == Entity.Type.Undefined:
#					print("object is assigned to ", ob)
#					answer = clause_excute(clause)
##					var new_var = create_variable(sub.identifier, ob.inherit, ob.data)
##					print("i remember ", new_var["_v"]["name"])
#
#				elif sub.type == Entity.Type.Variable or sub.type == Entity.Type.Class or sub.type == Entity.Type.Pronoun:
#					answer = clause_check(subject, do)
##					var yes = is_value(sub.data, ob.data)
##					if yes:
##						answer = "yes"
##					else:
##						answer = "no"
#
#				else:
#					printerr("Unhandled code!")
		else:
			clause_do(clause)
	
	elif do.count == 2:
		if do.verb[0] == "is" or do.verb[0] == "are":
			pass
	else:
		printerr("Uncatched 268")
		print(do)
	
	return answer

func execute_relative(clause:Clause):
	var subject:Noun = clause.subject
	var do:Task = clause.task
	var object:Noun = clause.task.object
	var relative = clause.relative
	var answer:String = "ok"
	print("on relative")
	if do.count == 1:
		if do.has("is") or do.has("are"):
			if subject.count == 0 or object.count == 0:
				var topic = clause.last_entity()
				if relative == "who":
					var res:Array = find_equal_value(topic.data)
					answer = " ".join(topic.identifier as PackedStringArray)
					answer += " is " + collect_speech(res, "and")
		
		elif do.has("do"):
			if subject.count == 0 or object.count == 0:
				var topic = clause.last_entity()
				var topic_do = topic.data["_do"]
				if relative == "what":
					var is_doing:String
					for k in topic_do:
						if topic_do[k]["status"] == "do":
							is_doing = data["verb"][k]["ing"]
					answer = "".join(topic.identifier as PackedStringArray)
					if is_doing == "":
						answer += " do nothing"
					else:
						answer += " is " + is_doing
		
	else:
		print("unhandled code 268")
		print(do.count)
	return answer

func clause_check(clause:Clause):
	var subject:Noun = clause.subject
	var do:Task = clause.task
	var object:Noun = do.object
	var conjunction = clause.conjunction
	var answer:String = "ok"
	
	if do.count == 1:
		if do.has("is") or do.has("are"):
			var ob = object.entities[0]
			for j in range(subject.count):
				var sub = subject.entities[j] as Entity
				
				if sub.type == Entity.Type.Undefined:
					printerr("Undefined subject is uncheckable!")
					answer = "ERROR!"
				elif sub.type == Entity.Type.Variable or sub.type == Entity.Type.Pronoun:
					var yes = is_value(sub.data, ob.data)
					if yes:
						answer = "yes"
					else:
						answer = "no"
				else:
					printerr("Unhandled code!")
	else:
		printerr("Unhandled code 329")
	return answer

func clause_assign(clause:Clause):
	var subject:Noun = clause.subject
	var do:Task = clause.task
	var object:Noun = do.object
	var conjunction = clause.conjunction
	var answer:String = "ok"
	
	var ob = object.entities[0]
	for j in range(subject.count):
		var sub = subject.entities[j] as Entity
		
		if sub.type == Entity.Type.Undefined:
			print("object is assigned to ", ob)
			var new_var = create_variable(sub.identifier, ob.inherit, ob.data)
			print("i remember ", new_var["_p"]["name"])
			
		elif sub.type == Entity.Type.Variable or sub.type == Entity.Type.Pronoun:
			assign_a_value(sub.data, ob.data)
			
		else:
			printerr("Unhandled code! 349")

func clause_do(clause:Clause):
	var subject:Noun = clause.subject
	var do:Task = clause.task
	var object:Noun = do.object
	var conjunction = clause.conjunction
	var answer:String = "ok"
	
	for j in range(subject.count):
		var sub = subject.entities[j] as Entity
		var sub_do:Dictionary = sub.data["_do"]
		if sub.type == Entity.Type.Variable or sub.type == Entity.Type.Pronoun:
			var verb = do.verb[0]
			if sub_do.has(verb):
				if sub_do[verb]["status"] == "do":
					answer = "yes"
			else:
				sub_do[verb] = {}
				sub_do[verb].merge(verb_template.duplicate(true))
				sub_do[verb]["status"] = "do"
	
	return answer

func clause_excute(clause:Clause):
	var subject:Noun = clause.subject
	var do:Task = clause.task
	var object:Noun = clause.task.object
	var conjunction = clause.conjunction
	var answer:String = "ok"
	
	if do.count == 1:
		if do.has("is") or do.has("are"):
			var ob = object.entities[0]
			for j in range(subject.count):
				var sub = subject.entities[j] as Entity
				
				if sub.type == Entity.Type.Undefined:
					print("object is assigned to ", ob)
					var new_var = create_variable(sub.identifier, ob.inherit, ob.data)
					print("i remember ", new_var["_p"]["name"])
					
				elif sub.type == Entity.Type.Variable or sub.type == Entity.Type.Pronoun:
					assign_a_value(sub.data, ob.data)
					
				else:
					printerr("Unhandled code! 354")
	return answer

class Clause:
	var type:En.CLAUSE_TYPE
	var string:String
	var state:State
	
	var subject:Noun
	var task:Task
	var infinitive:Infinitive
	var prepositions:Array[Preposition]
	var adverb:Adverb
	var composition:Array
	var end:String
	
	var conjunction:String
	var nextclause:Clause
	
	var relative:String
	var relativeposition:String
	
	func _init():
		type = En.CLAUSE_TYPE.none
		subject = Noun.new()
		task = Task.new()
		infinitive = Infinitive.new()
		adverb = Adverb.new()
	
	func find_pronoun(pronouns:PackedStringArray):
		var result = []
		var entities:Array
		
		for i in range(subject.count):
			var sub = subject.entities[i]
			var vardata = SBA.find_variable_by_name(sub.identifier)
			if vardata.size() == 0:
				continue
			if SBA.is_pronoun(vardata, pronouns):
				result.append(sub)
		
		if task.has_object():
			var object = task.object
			for i in range(object.count):
				var ob = object.entities[i]
				var vardata = SBA.find_variable_by_name(ob.identifier)
				if vardata.size() == 0:
					continue
				if SBA.is_pronoun(vardata, pronouns):
					result.append(ob)
		
		return result
	
	func append(element:En.PHRASE_TYPE):
		composition.append(element)
	
	func similiar(clause:Clause):
		var result:Dictionary = {}
		
		if self.subject.count == clause.subject.count:
			result["SUB"] = true
		
		return result
	
	func last_entity():
		
		if task.object.count != 0:
			return task.object.back()
		elif subject.count != 0:
			return subject.back()
		else:
			return null
	
	func has_relative()->bool:
		if relative == "":
			return false
		else:
			return true
	
#	enum CLAUSE_SIMILIAR {
#		NO_SIMILIAR = 0,
#		SUBJECT = 1,
#		OBJECT = 2,
#		VERB = 4,
#	}
	
	func check():
		if subject.has_undefined:
			self.state = State.TELL
		else:
			self.state = State.ASK
	
	enum State {
		TELL,
		ASK
	}
	
	func print():
		var str:String = ""
		str += En.CLAUSE_TYPE.keys()[type] + " Clause "
		str += "\"" + self.string + self.end + "\""
		return str
	
	func _to_string():
		var str:String = ""
		if self.nextclause == null:
			str = self.print()
		else:
			str += "[" + self.print()
			var thisclause = self.nextclause
			while thisclause != null:
				str += ", " + thisclause.print()
				thisclause = thisclause.nextclause
			str += "]"
		return str

class Noun:
	var count:int
	var entities:Array[Entity]
	var conjunction:String
	var type:Type
	var has_undefined:bool
	
	func _init():
		count = 0
		type = Type.none
	
	func init(phrases:Array, index:int, clause):
		var firstentity:int = -1
		var expectedconjunction:bool = false
		var conjunction:String = ""
		var run:bool = true
		while run:
#			print("noun init index ", index)
			if index >= phrases.size():
				break
			
			var next = phrases[index]
			if next is English.SC:
				var nextsc:English.SC = next
				if nextsc.c == ",":
					expectedconjunction = false
					index += 1
					continue
				
			var phrase:English.Phrase = phrases[index]
			if (phrase.type == En.PHRASE_TYPE.Noun or phrase.type == En.PHRASE_TYPE.Pronoun or phrase.type == En.PHRASE_TYPE.Undefined) and !expectedconjunction:
				var entity = Entity.new()
				index = entity.init(phrases, index)
				if index == -1:
					printerr("Error in entity!")
					return -1
				else:
					append(entity)
					retype(entity.type)
#					print("type now ", type)
					if firstentity == -1:
						firstentity = index
				
				if conjunction:
					break
				expectedconjunction = true
				
			elif phrase.type == En.PHRASE_TYPE.Conjunctive:
				if ["and", "or"].has(phrase.speech[0]):
					expectedconjunction = false
					conjunction = phrase.speech[0]
					index += 1
			else:
				break
		
		if count > 1:
			self.conjunction = conjunction
		if count > 1 and conjunction == "":
			entities.resize(1)
			index = firstentity
			count = 1
#		print(entities)
		if clause != null:
			clause.string += self.print() + " "
		else:
			printerr("Clause append are not requested!")
#		print("type now ", type)
		return index
	
	func size()->int:
		return count
	
	func front():
		if count > 0:
			return entities.front()
		else:
			return null
	
	func back():
		if count > 0:
			return entities.back()
		else:
			return null
	
	func append(entity:Entity):
		entities.append(entity)
		count = entities.size()
	
	func is_all_defined()->bool:
		for entity in entities:
			if entity.type == Entity.Type.Undefined:
				return false
		return true
	
	
	func check(value)->bool:
		for i in range(count):
			var entity = entities[i]
			
			if entity.type == Entity.Type.Undefined:
				return false
			
			if SBA.is_value(entity.data, value):
				continue
			else:
				return false
		
		return true
	
	func retype(newtype, rezero = false):
		if newtype == Entity.Type.Undefined:
			has_undefined = true
		if rezero:
			type = Type.none
			has_undefined = false
		if type == Type.none:
			if Type.values().has(newtype):
				print("enum noun to ", Entity.Type.keys()[newtype], newtype)
				type = newtype
			else:
				type = Type.MIX
		elif type == Type.MIX:
			pass
		else:
			if type != newtype:
				type = Type.MIX
#				if type == Type.ALL_UNDEFINED:
#					type |= Type.MIX
	
	func print():
		var str:String = ""
		
		if count == 1:
			str = entities[0].print()
		elif count == 2:
			str = entities[0].print() + " " + self.conjunction + " " + entities[1].print()
		else:
			for i in range(self.count-1):
				str += entities[i].print() + ", "
			str += self.conjunction + self.back().print()
		
		return str
	
	enum Type{
		none,
		ALL_UNDEFINED = Entity.Type.Undefined,
		ALL_CLASS = Entity.Type.Class,
		ALL_VARIABLE = Entity.Type.Variable,
		MIX = 1024
	}

class Entity:
	var identifier:Array
	var inherit:String
	var data:Dictionary
	var type
	var adj:Adjective
	var article:String
	
	var pronoun:English.Phrase
	var reference:Entity
	
	func _init():
		type = Type.None
	
	func init(phrases:Array, index:int = 0) -> int:
		var phrase:English.Phrase = phrases[index]
		var pos:int = -1
		if phrase.type == En.PHRASE_TYPE.Noun:
			
			if phrase.find_speech(float(En.SPEECH_TYPE.Adjective)) != -1:
				var article = phrase.find_speech_type_all(float(En.SPEECH_TYPE.Adjective), float(En.Adjective.Article))
				if article.size() > 0:
					self.article = phrase.speech[article[0]]
			if phrase.find_speech(float(En.SPEECH_TYPE.Noun)) != -1:
				var proper = phrase.find_speech_type_all(float(En.SPEECH_TYPE.Noun), float(En.Noun.Proper))
				
				if proper.size() > 0:
					var proper_name = []
					if proper.size() == 1:
						pos = phrase.find_speech_type(float(En.SPEECH_TYPE.Noun), float(En.Noun.Proper))
						proper_name = [ phrase.speech[pos] ]
					elif proper.size() > 1:
						for i in range(proper.size()):
							proper_name.append(phrase.speech[i])
					data = SBA.find_variable_by_name(proper_name)
					if data.is_empty():
						printerr("For ", proper_name, ", English dataset is exist but not in SBA!")
						return -1
					print("data of proper is ", data)
					identifier.append_array(proper_name)
					type = Type.Variable
					return index + 1
				pos = phrase.find_speech_type(float(En.SPEECH_TYPE.Noun), float(En.Noun.Common))
				if pos != -1:
					var result = SBA.find_all_by_name(phrase.speech[pos])
					identifier.append(phrase.speech[pos])
					data = result[1]
					inherit = data["_c"]
					type = result[0]
					return index + 1
				print("non existance ", phrase.speech)
			elif phrase.find_speech(float(En.SPEECH_TYPE.Pronoun)) != -1:
				var protype = phrase.find_speech_type_all(float(En.SPEECH_TYPE.Pronoun), float(En.Noun.Proper))
				identifier.append_array(phrase.speech)
				data = {}
				type = Type.Relative
				return index + 1
		elif phrase.type == En.PHRASE_TYPE.Pronoun:
			type = Type.Pronoun
			pronoun = phrase
			var ref:Array
			print("SBA.sentences ", SBA.sentences)
#			return -1
			for i in range(SBA.sentences.size(), 0, -1):
				var sentence = SBA.sentences[0]
#				print("sfvnijsfncjiafsjcnafijbnafscjiafsnivnafsijnij ", SBA.sentences.size())
#				print("c is ", c)
				ref = sentence.find_pronoun(phrase.speech)
#				return -1
				if ref.size() != 0:
					break
			if ref.size() == 0:
				printerr("Failed to find ", "".join(phrase.speech as PackedStringArray))
				return -1
			
			identifier = phrase.speech
			reference = SBA.variabel_from_data(SBA.find_variable_by_name(ref[0].identifier))
			data = reference.data
			inherit = data["_c"]
			print("after pronoun declare ", reference)
			
		elif phrase.type == En.PHRASE_TYPE.Relative:
			identifier.append_array(phrase.speech)
			data = {}
			type = Type.Relative
		elif phrase.type == En.PHRASE_TYPE.Undefined:
			print("entity undefined")
			identifier.append_array(phrase.speech)
			data = {}
			type = Type.Undefined
		else:
			print("else condition")
		
		return index + 1
	
	func as_subject():
		pass
	
	func as_object():
		pass
	
	func assign(value:Dictionary):
		pass
	
	enum Type {
		None,
		Undefined = 1,
		Class = 2,
		Variable = 4,
		Relative = 8,
		Pronoun = 16,
		Gerund = 32
	}
	
	func print():
		var str:String
		if self.article != "":
			str += self.article + " "
		str += "".join(identifier as PackedStringArray)
		return str
	
	func _to_string():
		print("entity ", Entity.Type.keys())
		var s = "Entity: { "
		s += "Name = " + str((" ").join(self.identifier as PackedStringArray))
		if self.type == null:
			s += ", Type = Undefined"
		else:
			s += ", Type = " + Entity.Type.keys()[self.type]
			s += ", Data = " + str(self.data)
		s += " }"
		
		return s

class Task:
	var modal:PackedStringArray
	var verb:PackedStringArray
	var object:Variant
	var is_auxilary:bool
	var count:int = 0
	var adverb_front:Array
	
	func _init():
		object = Noun.new()
	
	func init(phrases:Array, index:int, clause = null) -> int:
		var phrase = phrases[index]
		
		var verb_vos = phrase.find_speech_all(En.SPEECH_TYPE.Verb) as Array
		for i in range(verb_vos.size()):
			verb.append(phrase.speech[verb_vos[i]])
		count = verb_vos.size()
		
		if verb_vos.front() != 0:
			for i in range(0, verb_vos.front()):
				adverb_front.append(phrase.speech[i])
		
		if clause != null:
			clause.string += self.print() + " "
		else:
			printerr("Clause append are not requested!")
		return index + 1
	
	func has(value:String):
		return verb.has(value)
	
	func has_object():
		if object == null:
			return false
		else:
			return true
	
	func is_empty()->bool:
		if count == 0:
			return true
		else:
			return false
	
	func print():
		var str:String = ""
		str += "".join(self.verb)
		return str
	
	func _to_string():
		var s = "Task: { "
		s += "Verb = " + str((" ").join(self.verb as PackedStringArray))
		s += ", Front = " + str([(" ").join(self.adverb_front as PackedStringArray)])
		s += " }"
		
		return s

class Adjective:
	var string:String
	var element:Array
	var type:En.Adjective
	var article:ARTICLE_TYPE
	
	func _init():
		article = ARTICLE_TYPE.NONE
	
	enum ARTICLE_TYPE {
		NONE,
		A,
		THE
	}

func parse_adjective(phrase:English.Phrase)->Array:
	var result = []
	for i in range(phrase.count):
		if phrase.speechtype[i][0] == En.SPEECH_TYPE.Adjective:
			var adj = Adjective.new()
			adj.string += phrase.speech[i] + " "
			
			continue
	return result

class Adverb:
	var adverb:Array
	var adverbtype:Array
	var count
	
	func _init():
		pass
	
	func init(phrases:Array, index:int) -> int:
		var phrase = phrases[index]
		
		var adverb_vos = phrase.find_speech_all(En.SPEECH_TYPE.Adverb) as Array
		for i in range(adverb_vos.size()):
			adverb.append(phrase.speech[adverb_vos[i]])
			adverbtype.append(phrase.speechtype[adverb_vos[i]][1])
		count = adverb_vos.size()
		
		return index + 1
	
	func _to_string():
		var s = "Clause Modifier: { "
		s += "Adverb = ["
		for i in range(count):
			s += str(self.adverb[i]) + " (" + str(En.Adverb.keys()[self.adverbtype[i]]) + "), "
		s = s.substr(0, s.length()-2)
#		s.erase(s.length() - 1, " ".unicode_at(0))
#		s.erase(s.length() - 1, ",".unicode_at(0))
		s += "] }"
		
		return s

func parse_adverb(phrase:English.Phrase)->Array:
	var result = []
	for i in range(phrase.count):
		if phrase.speechtype[i][0] == En.SPEECH_TYPE.Adverb:
			var adj = Adverb.new()
			adj.string += phrase.speech[i] + " "
			
			continue
	return result

class Preposition:
	var speech:String
	var type:En.Preposition
	var object:Noun
	
	func _init():
		object = Noun.new()
	
	func init(phrases:Array, index:int, clause):
		var phrase = phrases[index]
		self.speech = phrase.speech[0]
		self.type = phrase.speechtype[0][0]
		clause.string += self.speech + " "
		index += 1
		var next = phrases[index]
		if next is English.Phrase:
			var nextphrase = next as English.Phrase
			if nextphrase.type == En.PHRASE_TYPE.Noun:
				index = self.object.init(phrases, index, clause)
		
		return index
	
	enum PREPOSITION_TYPE{
		none
	}

class Infinitive:
	var verb:Task
	var object:Noun
	
	func _init():
		verb = Task.new()
		object = Noun.new()
	
	func init():
		pass

const verb_template = {
	"status": "",
	"start" : "",
	"finish": "",
	"long" : ""
}

func is_pronoun(data:Dictionary, pronouns:Array):
#	print(data, ", ", pronouns)
	if pronouns.size() == 1:
		var pronoun = pronouns[0]
		
		if pronoun == "he":
			if is_property_equal(data["_p"]["gender"], SBA.Classes["male"]["_v"]["gender"]):
				return true
		elif pronoun == "she":
			if is_property_equal(data["p"]["gender"], SBA.Classes["female"]["_v"]["gender"]):
				return true

func variabel_from_data(data:Dictionary)->Entity:
	var entity:Entity = Entity.new()
	entity.identifier = data["_p"]["name"]["_v"]
	entity.type = Entity.Type.Variable
	entity.data = data
	
	return entity

func find_class_by_name(name:String) -> Dictionary:
	var classes = data["class"] as Dictionary
	
	if classes.has(name):
		return classes[name]
	return {}

func find_variable_by_name(name) -> Dictionary:
	var variables = data["variable"] as Array
	var varcount = variables.size()
#	print("var ", variables, " ", varcount)
	
	if name is String:
		for i in range(varcount):
#			print(variables[i], " : ", typeof(variables[i]))
			var each = (variables[i] as Dictionary)["_p"]
			if each["name"]["_v"].has(name):
				return variables[i]
	elif name is Array:
		for i in range(varcount):
			print(variables[i])
			var each = (variables[i] as Dictionary)["_p"]
			if each["name"]["_v"] == name:
				return variables[i]
	return {}

func find_all_by_name(name) -> Array:
	var res:Dictionary = {}
	
	res = find_class_by_name(name)
	if !res.is_empty():
		return [Entity.Type.Class, res]
	res = find_variable_by_name(name)
	if !res.is_empty():
		return [Entity.Type.Variable, res]
	printerr("Not found! ", name)
	return [Entity.Type.Undefined, {}]

func create_variable(name:Array, inherit:String, value:Dictionary = {}) -> Dictionary:
	var new_var:Dictionary
	if inherit != "":
		new_var["_c"] = inherit
		new_var["_p"] = _instance_properties_values(inherit)
	else:
		new_var["_p"] = {}
	new_var["_do"] = {}
	new_var["_st"] = []
	print("properties ", new_var["_p"])
	new_var["_p"]["name"]["_v"] = name.duplicate(true)
	
	if not value.is_empty():
		assign_a_value(new_var, value)
	
	data["variable"].append(new_var)
	print("this is creating ", name)
	for i in range(name.size()):
		print("i ", i)
		English.add_data(name[i], En.SPEECH_TYPE.Noun, En.Noun.Proper)
	print("before back ", new_var)
	return new_var

func _instance_properties_values(inherit:String):
	var classes = data["class"]
	var instance_tree:Array = [inherit]
	var properties:Dictionary
	var _c = inherit
	while true:
		_c = classes[_c]["_c"]
		if _c == null:
			break
		else:
			instance_tree.append(_c)
#	print("instance tree ", instance_tree)
	for j in range(instance_tree.size()-1, -1, -1):
		_c = instance_tree[j]
		for k in classes[_c]["_p"]:
			properties[k] = {
				"_v" = null
			}
		for k in classes[_c]["_v"]:
			properties[k] = {
				"_v" : classes[_c]["_v"][k]["_v"]
			}
		
	return properties

func assign_a_value(thing:Dictionary, value:Dictionary):
	thing["_p"].merge(value["_v"], true)

func is_value(vardata:Dictionary, value) -> bool:
	var v:Dictionary
	var vkeys:Array
	var vval:Array
	var myprop = vardata["_p"]
	
	if myprop.is_empty():
		return false
	
	if value is String:
		v = find_class_by_name(value)
	elif value is Dictionary:
		v = value["_v"]
	
	vval = v.values()
	vkeys = v.keys()
	for i in range(v.size()):
		var key = vkeys[i]
		if myprop.has(key):
			if not is_property_equal(myprop[key], vval[i]):
#				print("comparing ", thing[key], " :: ", vval[i])
				return false
		else:
#			print("exiting ", key)
			return false
	
	return true

func is_least_value(thing:Dictionary, value) -> bool:
	var v:Dictionary
	var vkeys:Array
	var vval:Array
	
	if thing.is_empty():
		return false
	
	if value is String:
		v = find_class_by_name(value)
	elif value is Dictionary:
		v = value
	vkeys = v.keys()
	vval = v.values()
	for i in range(v.size()):
		var key = vkeys[i]
		if thing.has(key):
			if thing[key] != vval[i]:
				return false
		else:
			continue
	
	return true

#find value that equal to entity
func find_equal_value(thing:Dictionary) -> Array:
	print(thing)
	var prop:Dictionary = thing["_p"]
#	print(prop)
	var prop_count = prop.size()
	if prop.is_empty():
		return []
	var values = data["class"]
	var result:Array = []
	
	for each in values:
		var value:Dictionary = values[each]
		if !value.has("_v") or !value.has("_c"):
			continue
#		print(each)
		if thing["_c"] == value["_c"]:
			var value_vrop = value["_v"]
			var equal = true
			for k in value_vrop:
#				print(k)
#				print(prop)
				if !prop.has(k):
					continue
#				print(value_vrop[k])
				if !is_property_equal(prop[k], value_vrop[k]):
					equal = false
#					print("break at ", k)
					break
			if equal:
				result.append(each)
#	print(result)
	return result

func is_property_equal(val1:Dictionary, val2:Dictionary):
	var v1type = typeof(val1["_v"])
	var v2type = typeof(val2["_v"])
	
	if v1type == v2type:
		if val1["_v"] == val2["_v"]:
			return true
#	print(val1["_v"],  " ", val2["_v"])
	return false

func collect_speech(speeches:Array, connector:String) -> String:
	var s:String
	
	if speeches.is_empty():
		return "none"
	
	if "aiueo".find(str(speeches[0])[0]) == -1:
		s += "a "
	else:
		s += "an "
	s += str(speeches[0])
	
	if speeches.size() == 1:
		return s
	elif speeches.size() == 2:
		s += " " + connector + " " + speeches[1]
		return s
	else:
		for i in range(1, speeches.size()-1):
			s += ", " + str(speeches[i])
		s += ", " + connector + " " + speeches.back()
	
	return s

