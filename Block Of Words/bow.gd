@tool
extends Node

func _init():
	print("this is bow init")

func init():
	English.init(English.path)

func push(s:String):
	var coll = English.read(s)
	
	return parse(coll)

func parse(collection:English.Collection)->Block:
	var _base = Block.new("$")
	
	var subjectdone = false
	var verbdone = false
	var objectdone = false
	
	var index = 0
	var limit = collection.count
	while index < limit:
		var this = collection.elements[index]
		if this is English.Phrase:
			var phrase = this as English.Phrase
			_base.add_child(digest(collection, index))
		index += 1
	
	return _base

func digest(coll:English.Collection, index:int)->Block:
	var phrase = coll.elements[index] as English.Phrase
	var block = Block.new()
	
	if phrase.type == En.PHRASE_TYPE.Noun:
		var adjectives = phrase.find_speech_all(En.SPEECH_TYPE.Adjective)
		for adj in adjectives:
			if phrase.speechtype[adj][1] == En.Adjective.Article:
				block.add_child(new_block(phrase.speech[adj], adj)).atparent = adj
			else:
				block.add_child(new_block(phrase.speech[adj], adj)).atparent = adj
#		var article = phrase.find_speech_type(En.SPEECH_TYPE.Adjective, En.Adjective.Article)
#		if article != -1:
#			block.add_child(new_block(phrase.speech[article], article))
		
		var common = phrase.find_speech_type(En.SPEECH_TYPE.Noun, En.Noun.Common)
		if common != -1:
			block.re_set(phrase.speech[common], common)
			block.atchild = common
			return block
	elif phrase.type == En.PHRASE_TYPE.Adjective:
		pass
	elif phrase.type == En.PHRASE_TYPE.Verb:
		var verbs = phrase.find_speech_all(En.SPEECH_TYPE.Verb)
		
		if verbs.size() == 1:
			var auxilary = phrase.find_speech_type(En.SPEECH_TYPE.Verb, En.Verb.Auxiliary)
			if auxilary != -1:
				block.re_set(phrase.speech[auxilary], auxilary)
				block.atchild = auxilary
				return block
			var verb = phrase.find_speech(En.SPEECH_TYPE.Verb)
			block.re_set(phrase.speech[verb], verb)
			block.atchild = verb
			return block
		else:
			var auxilary = phrase.find_speech_type(En.SPEECH_TYPE.Verb, En.Verb.Auxiliary)
			var verb
			if auxilary != -1:
				block.re_set(phrase.speech[auxilary], auxilary)
				block.atchild = auxilary
				verb = phrase.find_speech(En.SPEECH_TYPE.Verb, auxilary+1)
				block.add_child(new_block(phrase.speech[verb], verb)).atparent = verb
			
			return block
	
	
	return null

func new_block(s:String = "", at:int = -1)->Block:
	return Block.new(s, at)

class Block:
	var words:PackedStringArray
	var atparent:int
	var atchild:int
	var child:Array[Block]
	var category:En.CATEGORY
	var type1
	var type2
	
	func _init(s:String = "", at:int = -1):
		if s != "":
			words.append(s)
		if at != -1:
			atparent = at
	
	func re_set(s:String = "", at:int = -1):
		if s != "":
			words.append(s)
		if at != -1:
			atchild = at
	
	func add_child(block:Block, at = -1)->Block:
		if at == -1:
			child.append(block)
			block.atparent = child.size()-1
		else:
			child.insert(at, block)
			block.atparent = at
		return block
	
	func find_child(name:String):
		for c in child:
			if c.word == name:
				return c
		return null
	
	func has_child(name:String)->bool:
		for c in child:
			if c.word == name:
				return true
		return false
	
	func print(tablevel:int = 0, withindex:bool = false)->String:
		var result:String
		if withindex:
			result += "(" + str(atparent) + ")"
			result += " ".join(words) 
			result += "(" + str(atchild) + ")"
		else:
			result += " ".join(words)
		var thistab = _tab_level(tablevel)
		var childtab = _tab_level(tablevel+1)
		if child.size() != 0:
			result += ": [\n"
			for c in child:
				print(c.words)
				result += childtab + c.print(tablevel + 1, withindex) + ",\n"
#			result = result.trim_suffix(",")
			result = result.substr(0, result.length()-2) + "\n"
			result += thistab + "]"
#		result += "\n"
		return result.c_unescape()
	
	func print_in_line(tablevel:int = 0)->String:
		var result = "[ " + " ".join(words)
		if child.size() != 0:
			result += ": ["
			for c in child:
				result += c.print_in_line(tablevel + 1) + ", "
#			result = result.trim_suffix(",")
			result = result.substr(0, result.length()-2) + ""
			result += "]"
#		result += "\n"
		return result.c_unescape() + " ]"
	
	func be_string(justchild:bool = true)->String:
		var s:String
		if justchild:
			if child.size() == 1:
					s += child[0].be_string(false)
			elif child.size() != 0:
#				print(words, child.size())
				for c in range(child.size()):
					s += child[c].be_string(false)
		else:
			if child.size() == 1:
				if atchild == 0:
					s += " ".join(words) + " "
					s += child[0].be_string(false)
				else:
					s += child[0].be_string(false)
					s += " ".join(words)
			elif child.size() != 0:
				print(words, child.size())
				for c in range(child.size()+1):
					if c == atchild:
						s += " ".join(words)
					else:
						s += child[c].be_string(false)
			else:
				s += " ".join(words)
		return s + " "
	
	static func _tab_level(l:int)->String:
		var s:String = ""
		for i in range(l):
			s += "\t"
		return s
	
	func _to_string():
		return self.print()
