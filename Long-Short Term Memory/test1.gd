@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var lstm = LSTM.new()
	var input:PackedFloat64Array = [1.0]
	lstm.init_memory()
	var result = lstm.forward(input)
	var result2 = [lstm.stm[-1]]
	print("LTM: ", lstm.ltm, " STM: ", lstm.stm)
	print(lstm)
	print(result)
	lstm.backward(input, 1, 100000, 0.1)
	lstm.init_memory()
	result = lstm.forward(input)
	result2.append(lstm.stm[-1])
	print("LTM: ", lstm.ltm, " STM: ", lstm.stm)
	print(result)
	print(lstm)
	print("before: ", result2[0], ", after: ", result2[1])
	print()
