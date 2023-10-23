@tool
extends EditorScript

func _run():
	var transformer:Transformer4 = Transformer4.new()
	transformer.load("res://Transformer/4/datatest.json")
	var wem = transformer.wem
	var result = transformer.forward_sentence_to_sentence("1 2")
	print(result)
	
	transformer.train(
		[wem.sentence_to_ids("1 2")],
		[wem.words_to_ids(["3", "4"])],
		10
	)

	result = transformer.forward_sentence_to_sentence("1 2")
	print(result)
	transformer.save("res://Transformer/4/datatest.json")
