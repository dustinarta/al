@tool
extends EditorScript

func _run():
	var transformer:Transformer4 = Transformer4.new()
	transformer.load("res://Transformer/4/datatest.json")
	transformer
	var wem = transformer.wem
	var input
	input = "1 2"
#	input = "5 6"
	var result = transformer.forward_sentence_to_sentence(input)
#	var result = transformer.forward_sentence_to_sentence("5 6")
	print(result)
#	return
	transformer.train(
		[wem.sentence_to_ids("1 2"), wem.sentence_to_ids("5 6")],
		[wem.words_to_ids(["3", "4"]), wem.words_to_ids(["7", "8"])],
		10
	)
	
	result = transformer.forward_sentence_to_sentence(input)
#	result = transformer.forward_sentence_to_sentence("5 6")
	print(result)
	transformer.save("res://Transformer/4/datatest.json")
