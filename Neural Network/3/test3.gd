@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var nn = NN3.new()
	nn.init([2, 4, 2, 3])
#	print(nn.layers)
	print(nn.forward([0, 1])[-1])
	print(nn.forward_by_id([1])[-1])
#	print(nn.layers)
