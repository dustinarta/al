@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var transformer:Transformer3 = Transformer3.new()
	transformer.load("res://Transformer/3/datatest3.json")
	var wem = transformer.wem
	var input
	var expected
	var this_input
	var this_expected
#	this_input = "1 2"
#	this_expected = ["3", "4", "2"]
#	this_input = "4 4 4"
#	this_expected = ["1", "1"]
#	this_input = "9 9 9"
#	this_expected = ["6", "7", "8"]
	this_input = "1 2 3"
#	this_expected = ["4", "5", "6"]
	
	var timestart = Time.get_ticks_usec()
#	print("susi baka")
	var result2
	var output
	output = transformer.forward_sentence_to_sentence(this_input)
	print("before training ", output)
	
#	return
	
#	transformer.train(
#		[wem.sentence_to_ids("1 2"), wem.sentence_to_ids("4 4 4"), wem.sentence_to_ids("9 9 9")],
#		[wem.words_to_ids(["3", "4", "2"]), wem.words_to_ids(["1", "1"]), wem.words_to_ids(["6", "7", "8"])],
#		2
#	)
	
#	transformer.train(
#		[wem.sentence_to_ids("1 2")],
#		[wem.words_to_ids(["3", "4", "2"])],
#		1
#	)
	
#	transformer.train(
#		[wem.sentence_to_ids("9 9 9")],
#		[wem.words_to_ids(["6", "7", "8"])],
#		100
#	)
	
	transformer.train(
		[wem.sentence_to_ids("1 2 3")],
		[wem.words_to_ids(["4", "5", "6"])],
		1
	)
	
#	transformer.train(
#		[wem.sentence_to_ids("4 4 4")],
#		[wem.words_to_ids(["1", "1"])],
#		10
#	)
	
	output = transformer.forward_sentence_to_sentence(this_input)
	print("after training  ", output)
	
#	input = wem.forward_sentence(
#		this_input
#	)
#	expected = wem.words_to_ids(
#		this_expected
#	)
#	result1 = transformer.forward_fast(input)
#	output = wem.backward(
#		result1
#	)
#	result2 = wem.rectify_backward(output, expected)
#	print(result2)
	transformer.save("res://Transformer/3/datatest3.json")
#	print(result1)
#	print(output)
	
	print(
		"spent time ", (Time.get_ticks_usec() - timestart)/1000000.0, " second"
	)
	
