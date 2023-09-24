@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var wem = WEM2.new()
#	wem.init(512)
	wem.load("res://Word Embedding/2/data.json")
	var res
	
	res = wem.standard_split_word(
		"Expressions are sequences of operators and their operands in orderly fashion. An expression by itself can be a statement too, though only calls are reasonable to use as statements since other expressions don't have side effects."
	)
	wem.append_word(res)
	res = wem.standard_split_word(
		"To iterate through a range, such as an array or table, a for loop is used. When iterating over an array, the current array element is stored in the loop variable. When iterating over a dictionary, the key is stored in the loop variable."
	)
	wem.append_word(res)
#	wem.save("res://Word Embedding/2/data.json")
#	print(res)
#	print(wem.word_dict)
#	print(wem.embedding)
