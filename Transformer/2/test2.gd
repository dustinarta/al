@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var transformer = Transformer2.new().init(512, 1)
	var wem = WEM2.new()
	wem.load("res://Word Embedding/2/data.json")
	var input = wem.forward_sentence(
		"the key is stored"
	)
	var expected = wem.words_to_ids(
		["in", "array", "as", "variable"]
	)
#	print(expected)
#	print(input)
	var result1
	var result2
	var output
	input = wem.forward_sentence(
	"the key is stored"
	)
	expected = wem.words_to_ids(
		["in", "array", "as", "variable"]
	)
	result1 = transformer.forward(input)
	output = wem.backward_sentence(
		result1
	)
	print(output)
	for i in range(100):
		input = wem.forward_sentence(
		"the key is stored"
		)
		expected = wem.words_to_ids(
			["in", "array", "as", "variable"]
		)
		result1 = transformer.forward(input)
		output = wem.backward(
			result1
		)
		result2 = wem.rectify_backward(output, expected)
		wem.learn_backward(result1, result2)
	input = wem.forward_sentence(
	"the key is stored"
	)
	expected = wem.words_to_ids(
		["in", "array", "as", "variable"]
	)
	result1 = transformer.forward(input)
	output = wem.backward_sentence(
		result1
	)
	print(output)
#	wem.save("res://Word Embedding/2/data.json")
#	print(result1)
#	print(output)
