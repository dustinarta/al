extends RefCounted

var __source_code_script:PackedStringArray
var __variables:Dictionary
var __functions:Dictionary

var GOAL
var TOPIC
var STATE
var MEMORY
var _mode

var _memory_path:String = "res://Sentence Based Algorithm/5/memory.json"
var _memory_clause_object:Array
var _memory_clause_line:Array
var _memory_words:Dictionary

func start():
	MEMORY = load(_memory_path).data
	_memory_clause_object = MEMORY["clause object"]
	_memory_clause_line = MEMORY["clause line"]
	_memory_words = MEMORY["word position"]

func sleep():
	pass

func input(_sentence):
	var sentence = _sentence
	print(sentence)
	var clause_count:int = sentence.size()
	
	if _mode == "listen":
		if clause_count == 1:
			var clause = sentence.clauses[0]
			var clause_type = clause.type
			if clause_type == "independent":
				_append_clause(clause)
			else:
				printerr("uncatched! clause type = ", clause_type)
		else:
			printerr("uncatched! clause count = ", clause_count)
	else:
		if clause_count == 1:
			var clause = sentence.clauses[0]
			var clause_type = clause.type
			print(clause_type)
			if clause_type == "relative":
				var relative = clause.find_part("relative")
				if relative == -1:
					printerr("invalid relative!")
					return null
				relative = clause.data[relative]["$"]
				
				if relative == "what":
					pass
				else:
					printerr("uncatched question")
				
				
			elif clause_type == "independent":
				_append_clause(clause)
			else:
				printerr("uncatched! clause type = ", clause_type)
		else:
			printerr("uncatched! clause count = ", clause_count)

func process():
	pass

func finish():
	var f = FileAccess.open(
		_memory_path, FileAccess.WRITE
	)
	f.store_string(
		JSON.stringify(MEMORY, "\t", false)
	)

# Additional variable and function

func _append_clause(clause):
	var this_words = clause.words as Array
	
	for c in _memory_clause_object:
		if this_words == c["words"]:
			print("already exist ", this_words)
			return
	
	var clause_index = _memory_clause_object.size()
	for w in this_words:
		if _memory_words.has(w):
			var word_position = _memory_words[w]
			if word_position.has(clause_index):
				continue
			else:
				word_position.append(clause_index)
		else:
			_memory_words[w] = [clause_index]
	
	print("adding clause ", this_words)
	_memory_clause_object.append(
		clause.to_dict()
	)
	_memory_clause_line.append(
		clause.words.duplicate()
	)


