tool
extends EditorScript


func _run():
	var nn = NeuralNetwork.new("my model", 1)
	nn.add_layer(4, NeuralNetwork.ACTIVATION.TANH)
	nn.add_layer(4, NeuralNetwork.ACTIVATION.TANH)
	nn.add_layer(4, NeuralNetwork.ACTIVATION.SIGMOID)
	nn.init_weight()
	nn.init_bias_all(1.0)
#	print(nn)
#	print(nn.forward([1.0]))
#	print(nn.error_point([0, 2], [0.0, 1.0, 0.5]))
	DL.Backpropagation.train2(nn, [[1.0], [2.0], [3.0], [4.0]], [
		[0.99, 0.01, 0.01, 0.01],
		[0.01, 0.99, 0.01, 0.01],
		[0.01, 0.01, 0.99, 0.01],
		[0.01, 0.01, 0.01, 0.99]
	], 
	40000, 0.01)
	print(nn)
	print(nn.forward([1.0]))
	print(nn.forward([2.0]))
	print(nn.forward([3.0]))
	print(nn.forward([4.0]))
