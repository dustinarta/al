@tool
extends EditorScript


func _run():
	var nn = NN.new(1)
#	nn.add_layer(100, NN.ACTIVATION.TANH)
	nn.add_layer(4, NN.ACTIVATION.NONE)
	nn.add_layer(4, NN.ACTIVATION.NONE)
	nn.add_layer(4, NN.ACTIVATION.NONE)
	nn.init_weight()
	nn.init_bias_all(2.0)
#	print(nn)
#	print(nn.forward([1.0]))
#	print(nn.error_point([0, 2], [0.0, 1.0, 0.5]))
	DL.Backpropagation.train2(nn, [[1.0], [2.0], [3.0], [4.0]], [
		[0.99, 0.01, 0.01, 0.01],
		[0.01, 0.99, 0.01, 0.01],
		[0.01, 0.01, 0.99, 0.01],
		[0.01, 0.01, 0.01, 0.99]
	], 
	100000, 0.01)
#	print(nn)
#	var firsttime = Time.get_ticks_usec()
	
	print(nn.forward([1.0])[-1])
#	print(Time.get_ticks_usec() - firsttime)
	print(nn.forward([2.0])[-1])
	print(nn.forward([3.0])[-1])
	print(nn.forward([4.0])[-1])
