tool
extends EditorScript


func _run():
	var nn = NN.new(2)
	nn.add_layer(4, NN.ACTIVATION.TANH)
	nn.add_layer(5, NN.ACTIVATION.SIGMOID)
	nn.add_layer(4, NN.ACTIVATION.TANH)
	nn.add_layer(3, NN.ACTIVATION.SIGMOID)
	nn.init_weight()
	nn.init_bias_all(10.0)
	print(nn)
	print(nn.forward([1.0, 0.5]))
#	print(nn.error_point([0, 2], [0.0, 1.0, 0.5]))
	DL.Backpropagation.train(nn, [1.0, 0.5], [0.50, 0.99, 0.01], 1000, 0.1)
	print(nn)
	print(nn.forward([1.0, 0.5]))
