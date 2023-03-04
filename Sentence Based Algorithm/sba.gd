tool
extends Node

var data
var variable:Array

var path = "res://Sentence Based Algorithm/memory.json"

var _has_init = false
func init(path:String = self.path):
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
	var adverb
	
	print(clause)
	
	var running = true
	while running:
		phrase = clause.phrases[pos]
		print("pos ", pos, " ", phrase)
		if phrase.type == En.PHRASE_TYPE.Noun or phrase.type == En.PHRASE_TYPE.Relative:
			if subject.size() == 0:
				var entity = Entity.new()
				pos = entity.init(clause.phrases, pos)
				subject.append(entity)
			else:
				var entity = Entity.new()
				pos = entity.init(clause.phrases, pos)
				print("entity data ", entity.data)
				object.append(entity)
		elif phrase.type == En.PHRASE_TYPE.Verb:
#			predicate.append_array(phrase.speech)
			pos = predicate.init(clause.phrases, pos)
			print(pos)
		elif phrase.type == En.PHRASE_TYPE.Adjective:
			pass
		elif phrase.type == En.PHRASE_TYPE.Adverb:
			adverb = Adverb.new()
			pos = adverb.init(clause.phrases, pos)
			print(adverb)
		elif phrase.type == En.PHRASE_TYPE.Undefined:
			if predicate.count == 0:
				var entity = Entity.new()
				pos = entity.init(clause.phrases, pos)
				subject.append(entity)
			else:
				print("Undefined object at ", pos)
		
		if pos >= limit:
			running = false
	
	print("subject ", subject)
	print("predicate ", predicate)
	print("object ", object)
	print("adverb ", adverb)
#	print(equal_to_value(subject[0].data))
#	print(is_value(subject[0].data, "woman"))
#	print(is_inherit(subject[0].data, "alive"))
	print(execute(subject, predicate, object))
#	English.save_data()
#	save(path)

class Entity:
	var name:Array
	var data:Dictionary
	var type
	var adjs:Array
	
	func _init():
		pass
	
	func init(phrases:Array, index:int = 0) -> int:
		var phrase = phrases[index]
		var pos:int = -1
		if phrase.type == En.PHRASE_TYPE.Noun:
			
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
					if data.empty():
						printerr("For ", proper_name, ", English dataset is exist but not in SBA!")
						return -1
					print("data of proper is ", data)
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
			name.append_array(phrase.speech)
			data = {}
			type = ENTITY_TYPE.Relative
		elif phrase.type == En.PHRASE_TYPE.Undefined:
			print("entity undefined")
			name.append_array(phrase.speech)
			data = {}
			type = ENTITY_TYPE.Undefined
		else:
			print("else condition")
		
		return index + 1
	
	func _find_variable(name:Array):
		pass
	
	enum ENTITY_TYPE {
		Undefined
		Class
		Relative
		Variable
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
	
	func _init():
		pass
	
	func init(phrases:Array, index:int) -> int:
		var phrase = phrases[index]
		
		var verb_pos = phrase.find_speech_all(En.SPEECH_TYPE.Verb) as Array
		for i in range(verb_pos.size()):
			verb.append(phrase.speech[verb_pos[i]])
		count = verb_pos.size()
		
		if verb_pos.front() != 0:
			for i in range(0, verb_pos.front()):
				adverb_front.append(phrase.speech[i])
		
		
		return index + 1
	
	func has(value:String):
		print(verb.has(value))
		return verb.has(value)
	
	func _to_string():
		var s = "Task: { "
		s += "Verb = " + str((self.verb as PoolStringArray).join(" "))
		s += ", Front = " + str([(self.adverb_front as PoolStringArray).join(" ")])
		s += " }"
		
		return s

class Adjective:
	var speech:Array
	var speechtype:Array
	var adv:Adverb

class Adverb:
	var adverb:Array
	var adverbtype:Array
	var count
	
	func _init():
		pass
	
	func init(phrases:Array, index:int) -> int:
		var phrase = phrases[index]
		
		var adverb_pos = phrase.find_speech_all(En.SPEECH_TYPE.Adverb) as Array
		for i in range(adverb_pos.size()):
			adverb.append(phrase.speech[adverb_pos[i]])
			adverbtype.append(phrase.speechtype[adverb_pos[i]][1])
		count = adverb_pos.size()
		
		return index + 1
	
	func _to_string():
		var s = "Clause Modifier: { "
		s += "Adverb = ["
		for i in range(count):
			s += str(self.adverb[i]) + " (" + str(En.Adverb.keys()[self.adverbtype[i]]) + "), "
		s.erase(s.length() - 1, " ".ord_at(0))
		s.erase(s.length() - 1, ",".ord_at(0))
		s += "] }"
		
		return s

class Preposition:
	var speech:Array
	
	func _init():
		pass
	
	func init(phrases:Array, index:int):
		var phrase = phrases[index]

func execute(subject:Array, do:Task, object:Array, prepositions:Array = []):
	
	if do.count == 1:
		
		if do.has("is"):
			
			for j in range(subject.size()):
				var sub = subject[j] as Entity
				
				if sub.type == Entity.ENTITY_TYPE.Undefined:
					print("object is assigned to ", object[0])
					_remember_thing(sub.name, object[0].data["_c"], object[0].data)
					print("i remember")
				elif sub.type == Entity.ENTITY_TYPE.Variable:
					for i in range(0):
						pass
				elif sub.type == Entity.ENTITY_TYPE.Relative:
					var relative = sub.name[0]
					if relative == "who":
						print("object ", object[0].data)
						var res:Array = equal_to_value(object[0].data)
						var answer:String = (object[0].name as PoolStringArray).join(" ")
						answer += " is " + collect_speech(res, "and")
						return answer
		elif do.has("are"):
			pass
	
	print(data["variable"])
	print(variable)

func conjunction(con:Array, subject:Array, do:Task, object:Array):
	pass

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
			var each = (variables[i])["_p"]
			if each["name"]["_v"].has(name):
				return variables[i]
	elif name is Array:
		for i in range(varcount):
			var each = (variables[i] as Dictionary)["_p"]
			if each["name"]["_v"] == name:
				return variables[i]
	return {}

func find_value_by_name(name:String) -> Dictionary:
	var values = data["value"] as Dictionary
	
	if values.has(name):
		return values[name]
	return {}

func find_all_by_name(name:String) -> Array:
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

func create_variable(name:Array, inherit:String, value:Dictionary = {}) -> Dictionary:
	var result:Dictionary
	result["_c"] = inherit
	result["_p"] = _instance_properties(inherit)
	result["_st"] = []
	var p = result["_p"]
#	print(p)
	p["name"]["_v"] = name.duplicate(true)
	return result

func _instance_properties(inherit:String):
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
#		print("_c ", _c)
		for k in classes[_c]["_p"]:
			properties[k] = {
				"_v" : null
			}
	
	return properties

func assign_value(thing:Dictionary, value:Dictionary):
	thing["_p"].merge(value["_p"], true)

func _remember_thing(name:Array, parent:String, value:Dictionary):
	var new_var = create_variable(name, parent) as Dictionary
	assign_value(new_var, value)
#	new_var["_st"].append()
#	print("creating ", name)
	data["variable"].append(new_var)
	for i in range(name.size()):
		print("i ", i)
		English.add_data(name[i], En.SPEECH_TYPE.Noun, En.Noun.Proper)

func is_inherit(thing:Dictionary, name_class:String):
	var classes:Dictionary = data["class"]
#	print(classes.keys())
#	print(thing)
	var _c = thing["_c"]
	
	while true:
		if _c == null:
			break
		elif _c == name_class:
			return true
		var c = classes[_c]
		_c = c["_c"]
		
	
	return false

func is_value(_thing:Dictionary, value) -> bool:
	var v:Dictionary
	var vkeys:Array
	var vval:Array
	var thing = _thing["_p"]
	
	if thing.empty():
		return false
	
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

func is_least_value(thing:Dictionary, value) -> bool:
	var v:Dictionary
	var vkeys:Array
	var vval:Array
	
	if thing.empty():
		return false
	
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
	var result
	for j in range(values.size()):
		var value = values[j]
		for p in value["_p"]:
			result[p] = 0

func _get_value(base:String, key:String):
	var result
	var prop
	var _prop
	
	result = SBA.find_value_by_name(base)
	_prop = result["_p"]
	
	for k in _prop:
		var val = 0

#find value that equal to entity
func equal_to_value(thing:Dictionary) -> Array:
	print(thing)
	var prop = thing["_p"]
	if prop.empty():
		return []
	var values = data["value"]
	var result:Array = []
	
	for each in values:
		var value:Dictionary = values[each]
		
		if !value.has("_p") or !value.has("_c"):
			continue
		if thing["_c"] == value["_c"]:
			var equal = true
			for k in value["_p"]:
				print(k)
				print(prop)
				print(value["_p"])
				if prop[k].hash() != value["_p"][k].hash():
					equal = false
					break
			if equal:
				result.append(each)
	print(result)
	return result

func equal_by(thing:Dictionary, entity_type:int = Entity.ENTITY_TYPE.Value) -> Array:
	var result:Array = []
	
	if entity_type == Entity.ENTITY_TYPE.Class:
		result.append(thing["_c"])
	else:
		print(Entity.ENTITY_TYPE.keys()[entity_type], " is not written")
	
	return result

func has_similar(entities:Array):
	pass

func collect_speech(speeches:Array, connector:String) -> String:
	var s:String
	
	if speeches.empty():
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

