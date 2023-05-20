tool
extends EditorScript


func _run():
	var nn = NN.new(1)
	nn.add_layer(2, NN.ACTIVATION.NONE)
	nn.add_layer(1, NN.ACTIVATION.NONE)
	nn.init_weight()
	nn.init_bias_all(1.0)
#	print(nn)
#	print(nn.forward([1.0]))
#	print(nn.error_point([0, 2], [0.0, 1.0, 0.5]))
	DL.Backpropagation.train2(nn, [[0.01], [0.99]], [
		[-1.0],
		[10.0]
	], 
	10000, 0.1)
	print(nn)
	print(nn.forward([0.01]))
	print(nn.forward([0.99]))
