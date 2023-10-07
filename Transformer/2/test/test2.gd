@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var vector_size = 4
	var sequence_length = 1
	var transformer:Transformer2 = Transformer2.new()
	transformer.init(vector_size, 3)
	
	var input:Matrix = Matrix.new().init(sequence_length, vector_size).self_randomize(-1.0, 1.0)
	var expected:Matrix = Matrix.new().init(sequence_length, vector_size).self_randomize(-2.0, 2.0)
	
	var error
	var result1
	var result2
	var result3
	
	result1 = transformer.forward(input)
	error = result1.min_self(expected)
#	print(result1)
	print(error)
	
	for i in range(pow(vector_size, 2.0)):
		result1 = transformer.forward(input)
		error = result1.min_self(expected)
		transformer.learn_coder(error)
	
	result1 = transformer.forward(input)
	error = result1.min_self(expected)
	print(error)
	
