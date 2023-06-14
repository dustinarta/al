@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var multilstm = MultiLSTM.new()
	multilstm.init(4)
	
	print(multilstm.forward(
		[
			[1],
			[2],
			[3],
			[4]
		]
	))
