@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var nn = NN4Col.new()
	nn.init(4, 3, NN4Col.ACTIVATION.SOFTMAX)
	print(nn.forward([1, 2, 3, 4]))
	for i in range(10):
		nn.train([1, 2, 3, 4], [0, 0, 1])
	print(nn.forward([1, 2, 3, 4]))
