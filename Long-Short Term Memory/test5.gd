@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var inputs = [0.0, 0.5, 1.0, 0.1, 0.1]
	var lstm = LSTM.new()
	lstm._test_mode = true
	lstm.init()
	lstm.forward(inputs)
	print(lstm.stm)
	lstm.init_memory()
	lstm.backward_many(inputs, [-0.5, 0.5, 0.0, 0.1, 1.0], 10000, 0.1)
	lstm.forward(inputs)
	print(lstm.get_stm())
