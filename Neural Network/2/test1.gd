@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var nn = NN2.new(NN2.Layer.new(1, NN2.ActivationType.none))
	nn.add_layer(100, NN2.ActivationType.tanh)
	nn.add_layer(100, NN2.ActivationType.tanh)
#	print("layer ", nn.layers.size())
	var firsttime = Time.get_ticks_usec()
	nn.forward([1.0])
#	print()
	print(Time.get_ticks_usec() - firsttime)
#	print(nn.forward([3.2]))
