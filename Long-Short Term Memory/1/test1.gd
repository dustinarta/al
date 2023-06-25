@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var lstm = LSTM.new()
	lstm.init()
	var input:PackedFloat64Array = [0.01, 0.5, 0.25, 1.0]
	var expected = 0.5
	lstm.init_memory()
	var result = lstm.forward(input)
	var result2 = [lstm.stm[-1]]
	print("LTM: ", lstm.ltm, " STM: ", lstm.stm)
	print(lstm)
#	print(result)
	lstm.backward2(input, expected, 10000, 0.01)
	lstm.init_memory()
	result = lstm.forward(input)
	result2.append(lstm.stm[-1])
	print("LTM: ", lstm.ltm, "\nSTM: ", lstm.stm)
#	print(result)
	print(lstm)
	print("before: ", result2[0], ", after: ", result2[1])
	if abs(result2[1] - expected) <  abs(result2[0] - expected):
		print("better")
	else:
		print("worse")
	print()
	lstm.accuracy = abs(result2[1] - expected)
	var thisaccuracy = JSON.parse_string( ( FileAccess.open("res://Long-Short Term Memory/model.json", FileAccess.READ).get_as_text() ) )["last"]
	if lstm.accuracy < thisaccuracy:
		lstm.save("res://Long-Short Term Memory/model.json")
	else:
		print("comparing ", thisaccuracy , " < ", lstm.accuracy)
