@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var lstm = LSTM2.new()
	var res
	lstm.init()
	
	res = lstm.forward(0.5)
	print(res)
	
	for i in range(1000):
		lstm.train_with_expected(0.5, 0.5, 0.1)
	
	res = lstm.forward(0.5)
	print(res)
