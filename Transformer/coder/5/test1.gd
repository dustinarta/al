@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var vector_size:int = 64
	var sequence:int = 10
#	var input:Matrix = Matrix.new().init(sequence, vector_size, 1.0)
#	var input:Matrix = Matrix.new().init(sequence, vector_size).init_random_value(-1.0, 1.0)
	var input:Matrix = generate_input(sequence, vector_size)
#	var expected:Matrix = Matrix.new().init(sequence, vector_size).init_random_value(-2.0, 2.0)
	var expected:Matrix = generate_expected(sequence, vector_size)
	var coder = Coder5.new()
#	coder.init(vector_size, 4)
#	coder.save("res://Transformer/coder/5/datatest1.json")
#	return
	coder.load("res://Transformer/coder/5/datatest1.json")
#	coder.Value.data[0][0] = 0.1
	
#	var decode:Matrix = Matrix.new().init(vector_size, sequence, 1.0)
	var result = coder.forward(
		input, input
	)
#	var result2 = result.mul(decode)
	var error:Matrix = result.min(expected)
#	print(error.get_shape())
#	var next_error = error.mul_t(decode)
#	coder.save("res://Transformer/coder/5/datatest1.json")
#	next_error = error.mul_t(decode)
	print("before ", error.data[0], "\n")#
#	print("error mean ", error.row_mean(), "\n")
#	return
	
	for i in range(1):
		result = coder.forward(
			input, input
		)
#		result2 = result.mul(decode)
#		print(result.get_shape(), " ", decode.get_shape())
#		print(result2.get_shape(), " ", expected.get_shape())
		
		error = result.min(expected)
#		error.mul_self_by_number(0.001)
#		print(error.get_shape())
#		next_error = error.mul_t(decode)
#		decode.min_self(
#			result.transpose().mul(error).mul_self_by_number(0.001)
#		)
		coder.learn(error)
		
	
#	coder.save("res://Transformer/coder/5/datatest1.json")
	printerr("Unsaved")
	result = coder.forward(
		input, input
	)
#	result2 = result.mul(decode)
	error = result.min(expected)
#	next_error = error.mul_t(decode)
	print("after ", error.data[0])#
#	print(decode)
#	print(result.mul(decode).softmax())



func generate_expected(sequence, vector)->Matrix:
	var result:Matrix = Matrix.new().init(sequence, vector)
	
	for r in range(sequence):
		var row = result.data[r]
		for c in range(vector):
			row[c] = 1.0/((r + 1) * (c + 1)) - cos((r + 1) * (c + 1))
	return result

func generate_input(sequence, vector)->Matrix:
	var result:Matrix = Matrix.new().init(sequence, vector)
	
	for r in range(sequence):
		var row = result.data[r]
		for c in range(vector):
			row[c] = 1.0/((r + 1) * (c + 1)) + sin((r + 1) * (c + 1))
	return result

