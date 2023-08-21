@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var nn = NN5.new()
#	nn.init(2, [3, 4])
	nn.init(2, [3, 4, 5], [NN5.ActivationType.Tanh, NN5.ActivationType.Tanh, NN5.ActivationType.Tanh])
	var res
#	print(nn.Layers)
	print(nn.forward([1, 1]))
	for i in range(100):
		res = nn.backward([1, 1], [0.5, 0.5, 0.5, 0.5, 0.5])
#	print(res)
	print(nn.forward([1, 1]))
