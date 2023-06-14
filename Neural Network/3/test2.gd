@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var nn = NN3.new()
	nn.init([2, 4, 2, 3])
#	print(nn.layers)
	print(nn.forward([1, 2])[-1])
#	nn.backward([1, 2], [1, 1, 1], 10000, 0.01)
	nn._train_with_error([1, 2], [0.9, 0.9, 0.9])
#	print(nn.layers)
	print(nn.forward([1, 2])[-1])
#	print(nn.layers)
