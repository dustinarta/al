@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var vector_size:int = 64
	var sequence:int = 10
	var input:Matrix = generate_input(sequence, vector_size)
	var expected:Matrix = generate_expected(sequence, sequence)
	var coder1 = Coder5.new()
	var coder2 = Coder5.new()
#	coder1.init(vector_size, 4)
#	coder1.save("res://Transformer/coder/5/datatest1.json")
#	coder2.init(vector_size, 4)
#	coder2.save("res://Transformer/coder/5/datatest2.json")
#	return
	coder1.load("res://Transformer/coder/5/datatest1.json")
	coder2.load("res://Transformer/coder/5/datatest2.json")
	
	var decode:Matrix = Matrix.new()
#	decode = Matrix.new().init(vector_size, sequence).init_random_value(-1.0, 1.0)
#	decode.save("res://Transformer/coder/5/datatestdecode1.json")
#	return
	decode.load("res://Transformer/coder/5/datatestdecode1.json")
	var result = coder1.forward(
		input, input
	)
	result = coder2.forward(
		result, result
	)
	var result2 = result.mul(decode)
#	print(result2)
#	return
	var error:Matrix = result2.min(expected)
	var decode_learn = result.transpose().mul(error).mul_self_by_number(pow(10, -9)/pow(vector_size, 9.0))
#	print(decode_learn.data[0])
#	return
	#
	# Decode rate = 1000*pow(vector_size, 2.0)
	#				0.0001/pow(vector_size, 2.0)
	#
	var error2:Matrix = error.mul_t(decode)
	var coder2_error = error2.div_self_by_number(1000*pow(vector_size, 4.0))
	var coder1_error# = coder2.learn(coder2_error)
#	print(coder1_error.data[0], "\n")
#	print(error2)
#	print(coder2_error.data[0])
#	return
	print("before ", error.data[0], "\n")
#	return
	
	for i in range(2):
		result = coder1.forward(
			input, input
		)
		result = coder2.forward(
			result, result
		)
		result2 = result.mul(decode)
		error = result2.min(expected)
		decode_learn = result.transpose().mul(error).mul_self_by_number(pow(10, -9)/pow(vector_size, 9.0))
#		print(decode_learn.data[0])
		error2 = error.mul_t(decode)
		decode.min_self(
			decode_learn
		)
		coder2_error = error2.div_self_by_number(1000*pow(vector_size, 4.0))
#		print(coder2_error.data[0])
		coder1_error = coder2.learn(coder2_error)
#		print(coder1_error.data[0])
		coder1.learn(coder1_error)
	
	coder1.save("res://Transformer/coder/5/datatest1.json")
	decode.save("res://Transformer/coder/5/datatestdecode1.json")
	
	result = coder1.forward(
		input, input
	)
	result = coder2.forward(
		result, result
	)
	result2 = result.mul(decode)
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

