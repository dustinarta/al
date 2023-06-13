@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var better:float = 0
	var worse:float = 0
	var limit:int = 200
	var starttime:int = Time.get_ticks_msec()
	for i in range(limit):
		var lstm = LSTM.new()
		var input:PackedFloat64Array = [0.01, 0.5, -1]
		var expected = 0.5
		lstm.init_memory()
		var result = lstm.forward(input)
		var result2 = [lstm.stm[-1]]
#		print("LTM: ", lstm.ltm, " STM: ", lstm.stm)
#		print(lstm)
		#	print(result)
		lstm.backward(input, expected, 10000, 0.01)
		lstm.init_memory()
		result = lstm.forward(input)
		result2.append(lstm.stm[-1])
#		print("LTM: ", lstm.ltm, " STM: ", lstm.stm)
#		print(result)
#		print(lstm)
#		print("before: ", result2[0], ", after: ", result2[1])
		if abs(result2[1] - expected) <  abs(result2[0] - expected):
			better += 1
		else:
			worse += 1
#		print()
	print("taken time ", float(Time.get_ticks_msec()-starttime)/1000.0)
	print("on sample ", limit, " succes are ", float(better/limit) * 100, "%")
	better = 0
	starttime = Time.get_ticks_msec()
	for i in range(limit):
		var lstm = LSTM.new()
		var input:PackedFloat64Array = [0.01, 0.5, -1]
		var expected = 0.5
		lstm.init_memory()
		var result = lstm.forward(input)
		var result2 = [lstm.stm[-1]]
#		print("LTM: ", lstm.ltm, " STM: ", lstm.stm)
#		print(lstm)
		#	print(result)
		lstm.backward2(input, expected, 10000, 0.01)
		lstm.init_memory()
		result = lstm.forward(input)
		result2.append(lstm.stm[-1])
#		print("LTM: ", lstm.ltm, " STM: ", lstm.stm)
#		print(result)
#		print(lstm)
#		print("before: ", result2[0], ", after: ", result2[1])
		if abs(result2[1] - expected) <  abs(result2[0] - expected):
			better += 1
		else:
			worse += 1
#		print()
	print("taken time ", float(Time.get_ticks_msec()-starttime)/1000.0)
	print("on sample ", limit, " succes are ", float(better/limit) * 100, "%")
