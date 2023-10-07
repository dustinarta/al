@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var wem:WEM2 = WEM2.new()
	var vector_size = 20
	var sequence = 20
	wem.init(vector_size, sequence)
	wem.append_word("<p> 1 2 3 4 5".split(" ", false))
	
	var coder = Matrix.new()
	coder.init(sequence, vector_size)
	coder.self_randomize(-1.0, 1.0)
	
	var result1 = wem.backward(coder)
	var result2 = wem.rectify_backward(result1, [2, 0])
	print(wem.output_to_sentence(result1))
#	var result1 = wem.forward_sentence("1", 2)
	
	
	for i in range(1000):
		result1 = wem.backward(coder)
		result2 = wem.rectify_backward(result1, [2, 0])
		wem.learn_backward(coder, result2)
	
	result1 = wem.backward_sentence(coder)
	print(result1)
#	print(result2)
