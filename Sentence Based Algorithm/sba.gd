tool
extends Node

var data
var variable:Array

var path = "res://Sentence Based Algorithm/memory.json"

var _has_init = false
func init(path:String = "res://Sentence Based Algorithm/memory.json"):
	if _has_init == true:
		return
	
	English.init(English.path)
	print(English._has_init)
	
	var f:File = File.new()
	f.open(path, File.READ)
	data = JSON.parse(f.get_as_text()).result as Dictionary
	f.close()
	
	variable = data["variable"]
	
	_has_init = true

func save(path:String = ""):
	var f:File = File.new()
	f.open(path, File.WRITE)
	f.store_string(JSON.print(data, "\t"))
	f.close()

func push(s:String):
	var clause = English.read(s)
	var pos:int = 0
	var limit:int = clause.count
	var phrase
	var verbpos = clause.find_type(En.PHRASE_TYPE.Verb)
	var subject:Array
	var predicate:Task = Task.new()
	var object:Array
	
	print(clause)
	
	var running = true
	while running:
		phrase = clause.phrases[pos]
		print("pos ", pos, " ", phrase)
		if phrase.type == En.PHRASE_TYPE.Noun:
			if subject.size() == 0:
				var entity = Entity.new()
				pos = entity.init(clause.phrases, pos)
				subject.append(entity)
			else:
				var entity = Entity.new()
				pos = entity.init(clause.phrases, pos)
				object.append(entity)
		elif phrase.type == En.PHRASE_TYPE.Verb:
#			predicate.append_array(phrase.speech)
			pos = predicate.init(clause.phrases, pos)
		elif phrase.type == En.PHRASE_TYPE.Adjective:
			pass
		elif phrase.type == En.PHRASE_TYPE.Adverb:
			pass
		elif phrase.type == En.PHRASE_TYPE.Undefined:
			if predicate.count == 0:
				var entity = Entity.new()
				pos = entity.init(clause.phrases, pos)
				subject.append(entity)
			else:
				print("Undefined object at ", pos)
		
		if pos >= limit:
			running = false
	
	print(subject)
	print(predicate)
	print(object)
	print(equal_to_value(subject[0].data))
#	print(has_value(subject[0].data, "woman"))
#	print(is_inherit(subject[0].data, "alive"))
#	work(subject, predicate, object)

class Entity:
	var name:Array
	var speechtype:Array
	var data:Dictionary
	var type
	
	func _init():
		pass
	
	func init(phrases:Array, index:int = 0):
		var phrase = phrases[index]
		var pos:int = -1
		if phrase.type == En.PHRASE_TYPE.Noun:
			
			var proper = phrase.find_speech_type_all(float(En.SPEECH_TYPE.Noun), float(En.Noun.Proper))
			if proper.size() == 1:
				pos = phrase.find_speech_type(float(En.SPEECH_TYPE.Noun), float(En.Noun.Proper))
				data = SBA.find_variable_by_name(phrase.speech[pos])
				name.append_array(phrase.speech)
				type = ENTITY_TYPE.Variable
				return index + 1
			elif proper.size() > 1:
				var proper_name = []
				for i in range(proper.size()):
					proper_name.append(phrase.speech[i])
				data = SBA.find_variable_by_name(proper_name)
				name.append_array(proper_name)
				type = ENTITY_TYPE.Variable
				return index + 1
			pos = phrase.find_speech_type(float(En.SPEECH_TYPE.Noun), float(En.Noun.Common))
			if pos != -1:
				var result = SBA.find_all_by_name(phrase.speech[pos])
				name.append(phrase.speech[pos])
				data = result[1]
				type = result[0]
				return index + 1
			print("non existance ", phrase.speech)
		elif phrase.type == En.PHRASE_TYPE.Relative:
			type = ENTITY_TYPE.Relative
		elif phrase.type == En.PHRASE_TYPE.Undefined:
			print("undefined")
			name.append_array(phrase.speech)
#			name.append((phrase.speech as PoolStringArray).join(" "))
			type = ENTITY_TYPE.Undefined
			print(type, ENTITY_TYPE.Undefined)
		else:
			print("else condition")
		
		return index + 1
	
	enum ENTITY_TYPE {
		Undefined
		Class
		Variable
		Relative
		Value
	}
	
	func _to_string():
		var s = "Entity: { "
		s += "Name = " + str((self.name as PoolStringArray).join(" "))
		s += ", Type = " + ENTITY_TYPE.keys()[self.type]
		s += " }"
		
		return s

class Task:
	var verb:Array
	var count:int
	var adverb_front:Array
	var adverb_back:Array
	
	func _init():
		pass
	
	func init(phrases:Array, index:int):
		var phrase = phrases[index]
		
		var verb_pos = phrase.find_speech_all(En.SPEECH_TYPE.Verb) as Array
		for i in range(verb_pos.size()):
			verb.append(phrase.speech[verb_pos[i]])
		count = verb_pos.size()
		
		if verb_pos.front() != 0:
			for i in range(0, verb_pos.front()):
				adverb_front.append(phrase.speech[i])
		
		if verb_pos.back() != 0:
			for i in range(verb_pos.back(), phrase.count):
				adverb_back.append(phrase.speech[i])
		
		index += 1
		phrase = phrases[index]
		if phrase.type == En.PHRASE_TYPE.Adverb:
			for i in range(0, phrase.count):
				adverb_back.append(phrase.speech[i])
			return index + 1
		else:
			return index
	
	func has(value:String):
		print(verb.has(value))
		return verb.has(value)
	
	func _to_string():
		var s = "Task: { "
		s += "Verb = " + str((self.verb as PoolStringArray).join(" "))
		s += ", Front = " + str([(self.adverb_front as PoolStringArray).join(" ")])
		s += ", Back = " + str([(self.adverb_back as PoolStringArray).join(" ")])
		s += " }"
		
		return s

func work(subject:Array, do:Task, object:Array):
	print("work")
	if do.count == 1:
		print("count is 1")
		if do.has("is"):
			print("is")
			for j in range(subject.size()):
				print("j ", j)
				var sub = subject[j] as Entity
				print(sub.name)
				if sub.type == Entity.ENTITY_TYPE.Undefined:
					remember_thing(sub.name, object[0].data)
				elif sub.type == Entity.ENTITY_TYPE.Variable:
					for i in range(0):
						pass
					
		elif do.has("are"):
			pass
	
	English.save_data()
	save(path)
	print(data["variable"])
	print(variable)

func conjunction(con:Array, subject:Array, do:Task, object:Array):
	pass

func find_class_by_name(name:String):
	var classes = data["class"] as Dictionary
	
	if classes.has(name):
		return classes[name]
	return {}

func find_variable_by_name(name):
	var variables = data["variable"] as Array
	var varcount = variables.size()
	
	if name is String:
		for i in range(varcount):
			var each = variables[i] as Dictionary
			if each["name"].has(name):
				return each
	elif name is Array:
		for i in range(varcount):
			var each = variables[i] as Dictionary
			if each["name"] == name:
				return each
	return {}

func find_value_by_name(name:String):
	var values = data["value"] as Dictionary
	
	if values.has(name):
		return values[name]
	return {}

func find_all_by_name(name:String):
	var res:Dictionary = {}
	
	res = find_class_by_name(name)
	if !res.empty():
		return [Entity.ENTITY_TYPE.Class, res]
	res = find_variable_by_name(name)
	if !res.empty():
		return [Entity.ENTITY_TYPE.Variable, res]
	res = find_value_by_name(name)
	if !res.empty():
		return [Entity.ENTITY_TYPE.Value, res]
	
	return [Entity.ENTITY_TYPE.Undefined, {}]

func remember_thing(name:Array, value:Dictionary):
	var newvar:Dictionary = {
		"_c" : value["_c"],
		"name" : name
		}
	newvar.merge(value)
	print("var ", variable)
	variable.append(newvar)
	print("var ", variable)
	for i in range(name.size()):
		print("i ", i)
		English.add_data(name[i], En.SPEECH_TYPE.Noun, En.Noun.Proper)

func is_inherit(thing:Dictionary, name_class:String):
	var classes:Dictionary = data["class"].duplicate(true)
	classes.erase("_meta")
	print(classes.keys())
	var _c = thing["_c"]
	
	while true:
		if _c == null:
			break
		elif _c == name_class:
			return true
		var c = classes[_c]
		_c = c["_c"]
		
	
	return false

func has_value(thing:Dictionary, value):
	var v:Dictionary
	var vkeys:Array
	var vval:Array
	
	if value is String:
		v = find_value_by_name(value)
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
			return false
	
	return true

func has_least_value(thing:Dictionary, value):
	var v:Dictionary
	var vkeys:Array
	var vval:Array
	
	if value is String:
		v = find_value_by_name(value)
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

func _combine_value(values:Array):
	var result:Dictionary = {}
	for j in range(values.size()):
		var value = values[j] as Dictionary
		for i in range(value.size()):
			pass

func equal_to_value(thing:Dictionary) -> Array:
	var values = data["value"]
	var result:Array = []
	
	for vvalue in values:
		var value:Dictionary = values[vvalue]
#		print(value)
		var vvalue_c:String = value["_c"]
		if is_inherit(thing, vvalue_c):
			if thing.has_all(value.keys()):
				var equal = true
				for k in value:
					if thing[k] != value[k]:
						equal = false
						break
				if equal:
					result.append(vvalue)
	
	return result
