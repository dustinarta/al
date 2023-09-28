@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var transformer:Transformer2 = Transformer2.new()
	transformer.load("res://Transformer/2/data.json")
	transformer.wem.load("res://Word Embedding/2/data.json")
	var wem = transformer.wem
	
	
	var this_input
	var this_expected
#	this_input = "the key is stored"
#	this_expected = ["in", "array", "as", "variable"]
	
	this_input = "variable have side effects"
	this_expected = ["current", "element", "is", "iterating"]
	
	var result1
	var result2
	var result3
	var result4
	var result5
	var result6
	var result7
	
	result1 = transformer.forward_s(this_input)
	result2 = transformer.wem.rectify_backward(
		result1, transformer.wem.words_to_ids(this_expected)
	)
	result3 = transformer.Layer[0].__next_learn(result2)
	print(result3)
	
