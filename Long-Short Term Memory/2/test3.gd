@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var lstm = LSTM2.new()
	var res
	var input = [0.1, 0.2, 0.5]
	lstm.init()
	
	res = lstm.forward_many(input)
	print(lstm.get_output())
	
	print(lstm.calculate_all_error_with_error_for_stm(0.1))
#	for i in range(1000):
#		lstm.train_with_expected(0.5, 0.5, 0.1)
#
#	res = lstm.forward_many(input)
#	print(lstm.get_output())
