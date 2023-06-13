@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var nn = NN3.new([2, 4, 2, 3])
#	print(nn.layers)
	print(nn.forward([1, 2])[-1])
	nn.backward([1, 2], [1, 1, 1], 10000, 0.01)
#	print(nn.layers)
	print(nn.forward([1, 2])[-1])
#	print(nn.layers)
