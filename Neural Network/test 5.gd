tool
extends EditorScript


func _run():
	var nn = NeuralNetwork.new("my model", 1)
	nn.add_layer(10, NeuralNetwork.ACTIVATION.NONE)
	nn.add_layer(10, NeuralNetwork.ACTIVATION.NONE)
	nn.add_layer(1, NeuralNetwork.ACTIVATION.NONE)
	nn.init_weight()
	nn.init_bias_all(1.0)
	
	var size = 10
	var sin_input:Array
	sin_input.resize(size)
	var sin_output:Array
	sin_output.resize(size)
	
	for i in range(size):
		sin_input[i] = [i]
		sin_output[i] = [sin(i)]
	
#	print(nn)
#	print(nn.forward([1.0]))
#	print(nn.error_point([0, 2], [0.0, 1.0, 0.5]))
	NeuralNetwork.Backpropagation.train2(nn, sin_input, sin_output, 10000, 0.001)
	print(nn)
	for i in range(size):
		print("Expected: " + str(sin_output[i][0]))
		print(nn.forward(sin_input[i]))
