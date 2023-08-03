@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var nn = NN3.new()
	nn.init([2, 4], [NN3.ACTIVATION.NONE], true)
	nn.layers[0]["w"] = [
		0.1, 0.3, 0.1, 0.1, 0.2, -0.3, -0.1, 0.2
	]
	var res = nn.forward([0.1, 0.2])
#	print(res)
#	return
	var start = Time.get_ticks_usec()
	for i in range(10000):
		nn._train_many_with_expected(
			[
				[0.1, 0.2],
				[0.3, 0.1],
				[-0.2, 0.5]
			], 
			[
				[0.1, 0.1, 0.9, 0.1],
				[0.1, 0.9, 0.1, 0.1],
				[0.9, 0.1, 0.1, 0.1]
			]
		)
	
	print("NN time ", (Time.get_ticks_usec() - float(start))/1000000)
	res = nn.forward([0.1, 0.2])
	print(res)
	res = nn.forward([0.3, 0.1])
	print(res)
	res = nn.forward([-0.2, 0.5])
	print(res)
