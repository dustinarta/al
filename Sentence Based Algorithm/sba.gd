tool
extends Node

var data

var _has_init = false
func init(path:String = "res://Sentence Based Algorithm/memory.json"):
	if _has_init == true:
		return
	
	English.init()
	print(English._has_init)
	
	var f:File = File.new()
	f.open(path, File.READ)
	data = JSON.parse(f.get_as_text()).result as Dictionary
	#print(data)
	
	_has_init = true

func push(s:String):
	var clause = English.read(s)
	var pos:int = 0
	var limit:int = clause.count
	var phrase
	print("limit", limit)
	var verbpos = clause.find_type(En.PHRASE_TYPE.Verb)
	var subject:Entity = null
	var predicate:Array
	var object:Entity = null
	
	var running = true
	while running:
		
		phrase = clause.phrases[pos]
		if phrase.type == En.PHRASE_TYPE.Noun:
			if subject == null:
				subject = Entity.new()
				pos = subject.init(clause.phrases, pos)
			else:
				object = Entity.new()
				pos = object.init(clause.phrases, pos)
			
		elif phrase.type == En.PHRASE_TYPE.Verb:
			pass
		elif phrase.type == En.PHRASE_TYPE.Adjective:
			pass
		elif phrase.type == En.PHRASE_TYPE.Adverb:
			pass
		elif phrase.type == En.PHRASE_TYPE.Undefined:
			if subject == null and predicate.size() == 0:
				pass
		
		if pos >= limit:
			running = false
	
	print(subject.data)

class Entity:
	var data:Array
	var type
	
	func _init():
		print("this is entity")
	
	func init(phrases:Array, offset:int = 0):
		var phrase = phrases[offset] as English.Phrase
		
		if phrase.type == En.PHRASE_TYPE.Noun:
			var pos:int
			pos = phrase.find_speech_type(float(En.SPEECH_TYPE.Noun), float(En.Noun.Proper))
			if pos != -1:
				data.append(SBA.find_variable_by_name(phrase.speech[pos]))
				type = ENTITY_TYPE.Proper
		elif phrase.type == En.PHRASE_TYPE.Undefined:
			type = ENTITY_TYPE.Undefined
		else:
			print("else condition")
		
		return offset + 1
	
	enum ENTITY_TYPE {
		Undefined
		Common
		Proper
	}



func work(by:Entity, do:Array, into:Entity):
	
	if do.has("is") or do.has("are"):
		pass

func find_variable_by_name(name:String):
	var variables = data["variable"] as Array
	var varcount = variables.size()
	
	for i in range(varcount):
		var each = variables[i] as Dictionary
		if each["name"].has(name):
			return each
