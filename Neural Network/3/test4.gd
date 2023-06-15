@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var nn = NN3.new()
	nn.init(
		[3, 3, 3], 
		[NN3.ACTIVATION.SIGMOID, NN3.ACTIVATION.SOFTMAX, NN3.ACTIVATION.SIGMOID]
	)
	print(nn.forward([1, 1, 0])[-1])
	print(nn.forward([0, 1, 0])[-1])
	nn.backward_many(
		[
			[1, 1, 1],
			[0, 0, 0]
		],
		[
			[1, 1, 1],
			[0, 0, 0]
		],
		10000
	)
	print(nn.forward([1, 1, 1])[-1])
	print(nn.forward([0, 0, 0])[-1])
