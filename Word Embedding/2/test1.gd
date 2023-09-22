@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var wem = WEM2.new()
	wem.init(2)
	var res
	
	res = wem.standard_split_word(
		"Expressions are sequences of operators and their operands in orderly fashion. An expression by itself can be a statement too, though only calls are reasonable to use as statements since other expressions don't have side effects."
	)
#	print(res)
	wem.append_word(res)
	print(wem.word_dict)
	print(wem.embedding)
