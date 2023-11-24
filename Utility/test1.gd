@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.new().init(4, 4).init_random_value(-1.0, 1.0)
	var mat2:Matrix = Matrix.new().init(4, 4).init_random_value(-1.0, 1.0)
	
	
	var packedthread = PackedThread.new()
	packedthread.start_on_method(
		[
			mat1.activation_normalization,
			mat2.activation_normalization
		]
	)
	
	print(packedthread.wait_to_finish())
	
	
