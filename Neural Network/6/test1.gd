@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var nn = NN6.new()
	nn.init(2, [3, 4], true)
	var result
	result = nn.forward([0.2, 0.3])
	print(result)
