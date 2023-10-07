@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
#	var transformer:Transformer2 = Transformer2.new().init(16, 2)
#	transformer.wem.append_word("the key is stored in array as variable".split(" "))
#	transformer.save("res://Transformer/2/datatest.json")
#	return
	var transformer:Transformer2 = Transformer2.new()
	transformer.load("res://Transformer/2/datatest.json")
	var wem = transformer.wem
	var input = wem.forward_sentence(
		"the key is stored"
	)
	var expected = wem.words_to_ids(
		["in", "array", "as", "variable"]
	)
#	print(expected)
#	print(input)
	var this_input
	var this_expected
	this_input = "the key is stored"
	this_expected = ["in", "array", "as", "variable"]
	
#	this_input = "variable have side effects"
#	this_expected = ["current", "element", "is", "iterating"]
	
	var timestart = Time.get_ticks_usec()
	
	var result1
	var result2
	var output
	output = transformer.forward_sentence_to_sentence(this_input)
	print(output)
	
#	return
	
	
	for i in range(1):
		var input_id = wem.sentence_to_ids(this_input)
		input = wem.forward_sentence(
			this_input
		)
		expected = wem.words_to_ids(
			this_expected
		)
		result1 = transformer.forward(input)
		output = wem.backward(
			result1
		)
#		print(output)
#		return
		result2 = wem.rectify_backward(output, expected)
#		print(result2)
		var transformer_learn = wem.learn_backward(result1, result2)
#		print(transformer_learn)
#		return
		var wem_forward_error = transformer.learn_coder(transformer_learn)
#		return
#		wem.learn_forward(input_id, wem_forward_error)
	
	output = transformer.forward_sentence_to_sentence(this_input)
	print(output)
#	wem.save("res://Word Embedding/2/data.json")
	transformer.save("res://Transformer/2/datatest.json")
#	print(result1)
#	print(output)
	
	print(
		"spent time ", (Time.get_ticks_usec() - timestart)/1000000.0, " second"
	)
	
