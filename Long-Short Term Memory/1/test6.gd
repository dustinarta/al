@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var lstm = LSTM.new()
	lstm._test_mode = true
	lstm.init()
	var input = [0.0, 0.5, 1.0, 0.1, 0.1]
	var output = [-0.5, 0.5, 0.0, 0.1, 1.0]
	lstm.forward(input)
	print(lstm.get_stm())
	var error = []
	error.resize(input.size())
	for j in range(10000):
		for i in range(input.size()-1, -1, -1):
			error[i] = lstm.stm[i+1] - output[i]
#			print(lstm.stm[i+1], " - ", output[i], " = ", lstm.stm[i+1] - output[i])
		lstm._train_now_many_once_with_error(input, error, 0.1)
		lstm.forward2(input)
	lstm.forward2(input)
	print(lstm.get_stm())
