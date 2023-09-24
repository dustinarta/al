@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var wem = WEM2.new()
	wem.load("res://Word Embedding/2/data.json")
	var input
	var result
#	input = wem.parse("the key")
#	result = wem.forward(input)
	
	result = wem.backward_sentence(
		Matrix.new().init(4, wem.VECTOR_SIZE).shufle()
	)
	
	print(result)
