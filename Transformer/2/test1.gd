@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var transformer = Transformer2.new().init(512, 3)
	var wem = WEM2.new()
	wem.load("res://Word Embedding/2/data.json")
	var input = wem.forward_sentence(
		"the key is stored"
	)
#	print(input)
	var result
	var output
	result = transformer.forward(input)
	output = wem.backward_sentence(
		result
	)
#	print(result)
	print(output)
