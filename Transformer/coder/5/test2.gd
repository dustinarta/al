@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var vector_size:int = 64
	var sequence:int = 10
	var input:Matrix = generate_input(sequence, vector_size)
	var expected:Matrix = generate_expected(sequence, sequence)
	var coder = Coder5.new()
	coder.load("res://Transformer/coder/5/datatest1.json")
	
	var decode:Matrix = Matrix.new()
#	decode = Matrix.new().init(vector_size, sequence).init_random_value(-1.0, 1.0)
#	decode.save("res://Transformer/coder/5/datatestdecode1.json")
#	return
	decode.load("res://Transformer/coder/5/datatestdecode1.json")
	var result = coder.forward(
		input, input
	)
	var result2 = result.mul(decode)
	var error:Matrix = result2.min(expected)
	var decode_learn = result.transpose().mul(error).mul_self_by_number(0.0001/pow(vector_size, 3.0))
#	print(decode_learn)
	#
	# Decode rate = 1000*pow(vector_size, 2.0)
	#				0.0001/pow(vector_size, 2.0)
	#
	var error2:Matrix = error.mul_t(decode)
#	print(error2)
#	print(error2.div_self_by_number(vector_size).data[0])
#	return
	print("before ", error.data[0], "\n")
#	return
	
	for i in range(100):
		result = coder.forward(
			input, input
		)
		result2 = result.mul(decode)
		error = result2.min(expected)
		decode_learn = result.transpose().mul(error).mul_self_by_number(0.0001/pow(vector_size, 3.0))
		decode.min_self(
			decode_learn
		)
		error2 = error.mul_t(decode)
		coder.learn(error2)
	
	coder.save("res://Transformer/coder/5/datatest1.json")
	decode.save("res://Transformer/coder/5/datatestdecode1.json")
	
	result = coder.forward(
		input, input
	)
#	result2 = result.mul(decode)
	error = result2.min(expected)
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

