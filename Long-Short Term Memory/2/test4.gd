@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var nn1:NN4Row = NN4Row.new().init(3, 4, NN4Row.ACTIVATION.NONE)
	var multilstm:MultiLSTM2 = MultiLSTM2.new().init(4)
	var nn2:NN4Row = NN4Row.new().init(4, 5, NN4Row.ACTIVATION.SOFTMAX)
	
	var startinput = [0, 0, 1]
	var endoutput = [0, 0, 0, 1, 0]
	var input
	var output
	
	var next_input = nn1.forward(startinput)
	input = multilstm.forward(next_input)
	print(nn2.forward(input))
	
	for i in range(1000):
		next_input = nn1.forward(startinput)
		input = multilstm.forward(next_input)
		
		var multilstm_error = nn2.train(input, endoutput)
		var next_error = multilstm.train_with_error(multilstm_error)
		nn1.train_with_error(startinput, next_error)
		

	
	next_input = nn1.forward(startinput)
	input = multilstm.forward(next_input)
	print(nn2.forward(input))
	
