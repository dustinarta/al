@tool
extends Node

var allsentences:PackedSentence
var keys:Dictionary = {}

const BLOCKHEADER = "$"

func _init():
	print("this is bow init")

func init():
	English.init(English.path)
	allsentences = PackedSentence.new()
	keys = {}

func run(sentence:Sentence):
	if sentence.type == Sentence.SENTENCE_TYPE.Ask:
		var question
		question = sentence.find(SENTENCE_PART.QUESTION)
		if question == -1:
			printerr("Invalid question")
			return
		
	pass

func understand_sentence(sentence:Sentence):
	var childs:Array[Block] = sentence.block.child
	var has_subject:bool = false
	var has_verb:bool = false
	var has_object:bool = false
	
	var has_relative:bool = false
	var has_emptydescripton:bool = false
	for c in range(childs.size()):
		if childs[c].type2 == En.SPEECH_TYPE.Noun:
			if has_verb:
				if has_object:
					childs[c].sentence_part = SENTENCE_PART.OBJECT2
				else:
					childs[c].sentence_part = SENTENCE_PART.OBJECT
					has_object = true
			else:
				childs[c].sentence_part = SENTENCE_PART.SUBJECT
				has_subject = true
		elif childs[c].type2 == En.SPEECH_TYPE.Pronoun:
			if has_verb:
				if has_object:
					childs[c].sentence_part = SENTENCE_PART.OBJECT2
				else:
					childs[c].sentence_part = SENTENCE_PART.OBJECT
					has_object = true
			else:
				childs[c].sentence_part = SENTENCE_PART.SUBJECT
				has_subject = true
			if childs[c].type3 == En.Pronoun.Relative:
				
				has_relative = true
		elif childs[c].type2 == En.SPEECH_TYPE.Verb:
			if has_verb:
				childs[c].sentence_part = SENTENCE_PART.VERB2
			else:
				childs[c].sentence_part = SENTENCE_PART.VERB
				has_verb = true
		elif childs[c].type2 == En.SPEECH_TYPE.Preposition:
			if childs[c].total() == 1:
				childs[c].sentence_part = SENTENCE_PART.EMPTYDESCRIPTON
				has_emptydescripton = true
			else:
				childs[c].sentence_part = SENTENCE_PART.DESCRIPTON
	
	if has_relative or has_emptydescripton:
		sentence.type == Sentence.SENTENCE_TYPE.Ask

func answer(block:Block)->Block:
	var answer:Block = Block.new()
	
	return answer

func push(s:String):
	var coll = English.read(s)
	print(coll)
	var block = parse(coll)
	assign_block(block)
	allsentences.append(Sentence.new(block))
	return block

func parse(collection:English.Collection)->Block:
	var _base = Block.new(BLOCKHEADER)
	
	var subjectdone = false
	var verbdone = false
	var objectdone = false
	
	var index = 0
	var limit = collection.count
	while index < limit:
		var this = collection.elements[index]
		if this is English.Phrase:
			var phrase = this as English.Phrase
			var block:Block = Block.new()
			digest(block, collection, index)
			index += block.total() - phrase.count + 1
			_base.add_child(block)
		
	
	return _base

func digest(block, coll:English.Collection, index:int)->Block:
	var phrase = coll.elements[index] as English.Phrase
	
	if phrase.type == En.PHRASE_TYPE.Noun:
		var adjectives = phrase.find_speech_all(En.SPEECH_TYPE.Adjective)
		for adj in adjectives:
			if phrase.speechtype[adj][1] == En.Adjective.Article:
				block.add_child(new_block(phrase.speech[adj], adj)) \
				.set_atparent(adj).set_type2(En.SPEECH_TYPE.Adjective).set_type3(En.Adjective.Article)
			else:
				block.add_child(new_block(phrase.speech[adj], adj)) \
				.set_atparent(adj).set_type2(En.SPEECH_TYPE.Adjective).set_type3(phrase.speechtype[adj][1])
#		var article = phrase.find_speech_type(En.SPEECH_TYPE.Adjective, En.Adjective.Article)
#		if article != -1:
#			block.add_child(new_block(phrase.speech[article], article))
		
		var common = phrase.find_speech_type(En.SPEECH_TYPE.Noun, En.Noun.Common)
		if common != -1:
			block.re_set(phrase.speech[common], common) \
			.set_atchild(common).set_type2(En.SPEECH_TYPE.Noun).set_type3(En.Noun.Common)
			return block
	elif phrase.type == En.PHRASE_TYPE.Relative:
		block.re_set(phrase.speech[0]).set_atchild(0) \
		.set_type2(En.SPEECH_TYPE.Pronoun).set_type3(En.Pronoun.Relative)
#		index += 1
#		phrase = coll.elements[index]
#		if phrase is English.Phrase:
#			var childblock = Block.new()
#			digest(childblock, coll, index)
#			block.add_child(childblock).set_atparent(1)
#			return block
		return block
	elif phrase.type == En.PHRASE_TYPE.Adjective:
		pass
	elif phrase.type == En.PHRASE_TYPE.Verb:
		var verbs = phrase.find_speech_all(En.SPEECH_TYPE.Verb)
		
		if verbs.size() == 1:
			var auxilary = phrase.find_speech_type(En.SPEECH_TYPE.Verb, En.Verb.Auxiliary)
			if auxilary != -1:
				block.re_set(phrase.speech[auxilary], auxilary).set_atchild(auxilary) \
				.set_type2(En.SPEECH_TYPE.Verb).set_type3(En.Verb.Auxiliary)
			else:
				var verb = phrase.find_speech(En.SPEECH_TYPE.Verb)
				block.re_set(phrase.speech[verb], verb).set_atchild(verb) \
				.set_type2(En.SPEECH_TYPE.Verb).set_type3(phrase.speechtype[verb][1])
			return block
		else:
			var auxilary = phrase.find_speech_type(En.SPEECH_TYPE.Verb, En.Verb.Auxiliary)
			var verb
			var adverb
			if auxilary != -1:
				block.re_set(phrase.speech[auxilary], auxilary).set_atchild(auxilary) \
				.set_type2(En.SPEECH_TYPE.Verb).set_type3(En.Verb.Auxiliary)
				verb = phrase.find_speech(En.SPEECH_TYPE.Verb, auxilary+1)
				block.add_child(new_block(phrase.speech[verb])).set_atparent(1).set_atchild(verb-auxilary-1) \
				.set_type2(En.SPEECH_TYPE.Verb).set_type3(phrase.speechtype[verb][1])
			else:
				verb = phrase.find_speech(En.SPEECH_TYPE.Verb)
				block.re_set(phrase.speech[verb], verb) \
				.set_type2(En.SPEECH_TYPE.Verb).set_type3(phrase.speechtype[verb][1])
			adverb = phrase.find_speech(En.SPEECH_TYPE.Adverb)
			print("phrase adverb")
			print(phrase)
			if adverb != -1:
				print("have adverb")
				block.child[0].add_child(new_block(phrase.speech[adverb], 0)).set_atparent(adverb-verb+1) \
				.set_type2(En.SPEECH_TYPE.Adverb).set_type3(phrase.speechtype[adverb][1])
			return block
	elif phrase.type == En.PHRASE_TYPE.Prepositional:
		var prep = phrase.speechtype[0][1]
		
		if prep == En.Preposition.Specification:
			block.re_set(phrase.speech[0], 0) \
			.set_type2(En.SPEECH_TYPE.Preposition).set_type3(En.Preposition.Specification)
			index += 1
			phrase = coll.elements[index]
			if phrase is English.Phrase:
				var childblock = Block.new()
				block.add_child(digest(childblock, coll, index)).set_atparent(1)
				return block
			return block
	elif phrase.type == En.PHRASE_TYPE.Undefined:
		block.re_set(phrase.speech[0], 0)
		return block
	return null

func new_block(s:String = "", at:int = -1)->Block:
	return Block.new(s, at)

func assign_block(block:Block):
	for c in block.child:
		assign_block(c)
	var key = " ".join(block.words)
	if not keys.has(key):
		keys[key] = keys.size()

class PackedSentence:
	var sentences:Array[Sentence]
	
	func _init():
		pass
	
	func append(sentence:Sentence)->int:
		sentences.append(sentence)
		return sentences.size()-1
	
	func is_empty()->bool:
		if sentences.size() == 0:
			return true
		return false
	
	func select_by_key(key:int):
		var result:PackedSentence = PackedSentence.new()
		for s in range(sentences.size(), 0, -1):
			if sentences[s].has_key(key):
				result.append(sentences[s])
		return result
	
	func select_and_by_key(keys:PackedInt64Array):
		var result:PackedSentence = PackedSentence.new()
		for s in sentences:
			var thisis = true
			for key in keys:
				if not s.has_key(key):
					thisis = false
					break
			if thisis:
				result.append(s)
		return result
	
	func select_or_by_key(keys:PackedInt64Array):
		var result:PackedSentence = PackedSentence.new()
		for s in sentences:
			var thisis = false
			for key in keys:
				if s.has_key(key):
					thisis = true
					break
			if thisis:
				result.append(s)
		return result
	
	func select_by_word(word:String):
		var result:PackedSentence = PackedSentence.new()
		for s in sentences:
			if s.has_word(word):
				result.append(s)
		return result
	
	func select_and_by_word(words:PackedStringArray):
		var result:PackedSentence = PackedSentence.new()
		for s in sentences:
			var thisis = true
			for word in words:
				if not s.has_word(word):
					thisis = false
					break
			if thisis:
				result.append(s)
		return result
	
	func select_or_by_word(words:PackedStringArray):
		var result:PackedSentence = PackedSentence.new()
		for s in sentences:
			var thisis = false
			for word in words:
				if s.has_word(word):
					thisis = true
					break
			if thisis:
				result.append(s)
		return result
	
	func print()->String:
		var s:String
		for sen in sentences:
			s += "[ " + " ".join(sen.listword) + " ]\n"
		if s == "":
			s += "[<empty Packed Sentence>]"
		return s.c_unescape()
	
	func _to_string():
		return self.print()

class Sentence:
	var listword:PackedStringArray
	var listkey:PackedInt64Array
	var type:int
	var block:Block
	var connections:Array[Connection]
	
	enum SENTENCE_TYPE {
		Ask,
		Tell
	}
	
	func _init(block = null):
		if block is Block:
			init(block)
	
	func init(block:Block)->Sentence:
		if not block.words[0] == BLOCKHEADER:
			printerr("Invalid block")
		listword = block.sort()
		listkey.resize(listword.size())
		for i in range(listword.size()):
			listkey[i] = BOW.keys[listword[i]]
		self.block = block
		return self
	
	func find(part:SENTENCE_PART):
		var childs:Array[Block] = block.child
		for b in range(childs.size()):
			if childs[b].sentence_part == part:
				return b
		return -1
	
	func get_topic():
		var where = find(BOW.SENTENCE_PART.SUBJECT)
		if where == -1:
			where = find(BOW.SENTENCE_PART.OBJECT)
			if where == -1:
				return null
			else:
				return block.child[where]
		else:
			return block.child[where]
	
	func has_key(key:int):
		if listkey.has(key):
			return true
		else:
			false
	
	func has_word(word:String):
		if listword.has(word):
			return true
		else:
			false
	
	func print():
		var s:String
		for i in range(listword.size()):
			s += "[" + listword[i] + "][" + str(listkey[i]) + "]\n"
		return s.c_unescape()

class Connection:
	var conjunction:String
	var sentence_id:int
	
	const _list = {
		"REASON" : [
			"because", "so"
		],
		"COORDINATING" : [
			"and", "or", "but", "yet"
		]
	}
	
	func _init(_con:String, _id:int):
		conjunction = _con
		sentence_id = _id

"""
Doing the sentence connection
"""

class Block:
	var words:PackedStringArray
	var atparent:int
	var atchild:int
	var child:Array[Block]
	var category:En.CATEGORY
	var sentence_part:SENTENCE_PART
	var type1
	var type2
	var type3
	
	func _init(s:String = "", at:int = -1):
		if s != "":
			words.append(s)
		if at != -1:
			atparent = at
	
	func re_set(s:String = "", at:int = -1)->Block:
		if s != "":
			words.append(s)
		if at != -1:
			atchild = at
		return self
	
	func copy()->Block:
		var newblock:Block = Block.new()
		newblock.words = words.duplicate()
		newblock.atchild = atchild
		newblock.child = child.duplicate(true)
		newblock.category = category
		newblock.sentence_part = type1
		newblock.type2 = type2
		newblock.type3 = type3
		return newblock
	
	func add_child(block:Block, at = -1)->Block:
		if at == -1:
			child.append(block)
			block.atparent = child.size()-1
		else:
			child.insert(at, block)
			block.atparent = at
		return block
	
	func set_atparent(at:int)->Block:
		atparent = at
		return self
	
	func set_atchild(at:int)->Block:
		atchild = at
		return self
	
	func set_type1(type:int)->Block:
		type1 = type
		return self
	
	func set_type2(type:int)->Block:
		type2 = type
		return self
	
	func set_type3(type:int)->Block:
		type3 = type
		return self
	
	func find_child(name:String):
		for c in child:
			if c.word == name:
				return c
		return null
	
	func has_child(name:String)->bool:
		for c in child:
			if c.word == name:
				return true
		for c in child:
			if c.has_child(name):
				return true
		return false
	
	func total()->int:
		var total:int = 1
		for c in child:
			total += c.total()
		return total
	
	func sort(justchild:bool = true)->PackedStringArray:
		var result:PackedStringArray
		if justchild:
			if child.size() == 1:
					result.append_array(child[0].sort(false))
			elif child.size() != 0:
#				print(words, child.size())
				for c in range(child.size()):
					result.append_array(child[c].sort(false))
		else:
			if child.size() == 1:
				if atchild == 0:
					result.append(" ".join(words))
					result.append_array(child[0].sort(false))
				else:
					result.append_array(child[0].sort(false))
					result.append(" ".join(words))
			elif child.size() != 0:
#				print(words, child.size())
				for c in range(child.size()+1):
					if c == atchild:
						result.append(" ".join(words))
					else:
						result.append_array(child[c].sort(false))
			else:
				result.append(" ".join(words))
		return result
	
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
					s += child[0].be_string(false) + " "
			elif child.size() != 0:
#				print(words, child.size())
				for c in range(child.size()):
					s += child[c].be_string(false)
		else:
			if child.size() == 1:
				if atchild == 0:
					s += " ".join(words) + " "
					s += child[0].be_string(false) + " "
				else:
					s += child[0].be_string(false) + " "
					s += " ".join(words)
			elif child.size() != 0:
#				print(words, child.size())
				for c in range(child.size()+1):
					if c == atchild:
						s += " ".join(words) + " "
					else:
						s += child[c].be_string(false) + " "
			else:
				s += " ".join(words)
		return s 
	
	static func _tab_level(l:int)->String:
		var s:String = ""
		for i in range(l):
			s += "\t"
		return s
	
	func _to_string():
		return self.print()

enum SENTENCE_PART {
	QUESTION,
	SUBJECT,
	OBJECT,
	OBJECT2,
	VERB,
	VERB2,
	DESCRIPTON,
	EMPTYDESCRIPTON,
	ADVERB
}
