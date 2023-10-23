@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var wem:WEM2 = WEM2.new()
	var vector_size = 8
	var sequence = 100
	wem.init(vector_size, sequence)
	wem.append_word("<p> 1 2 3 4 5".split(" ", false))
	
	var coder:Matrix = Matrix.new().init(vector_size, vector_size)
#	coder.self_randomize(-0.5, 0.5)
	coder.self_randomize(-1.0/vector_size, 1.0/vector_size)
	var expected:Matrix = Matrix.new().init(sequence, vector_size)
	expected.self_randomize(-1.0, 1.0)
	
	var result1 = wem.forward_sentence("1 2")
	var result2 = result1.mul(coder).add(result1)
	var error = result2.min(expected)
	var learn = error.mul_t(coder)
	print(error)
#	return
	for i in range(1000):
		result1 = wem.forward_sentence("1 2")
		result2 = result1.mul(coder).add(result1)
#		error = expected.min(result2)
		error = result2.min(expected)
#		learn = error.mul_t(coder)
#		learn.mul_self_by_number(0.01)
		wem.learn_forward(error)
#	return
	
	result1 = wem.forward_sentence("1 2")
	result2 = result1.mul(coder).add(result1)
#	error = expected.min(result2)
	error = result2.min(expected)
	print(error)
#	learn = error.mul_t(coder)
	
