tool
extends EditorScript


func _run():
	var nn = NeuralNetwork.new("my model", 1)
	nn.add_layer(1, NeuralNetwork.ACTIVATION.TANH)
	nn.add_layer(2, NeuralNetwork.ACTIVATION.SIGMOID)
	nn.init_weight()
	nn.init_bias_all(0)
#	print(nn)
#	print(nn.forward([1.0]))
#	print(nn.error_point([0, 2], [0.0, 1.0, 0.5]))
	NeuralNetwork.Backpropagation.train2(nn, [[0.01], [0.99]], [
		[0.99, 0.01],
		[0.01, 0.99]
	], 
	100000, 0.1)
	print(nn)
	print(nn.forward([0.01]))
	print(nn.forward([0.99]))
