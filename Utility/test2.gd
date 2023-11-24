@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1 = Matrix.new().init(4, 4).init_random_value(-1.0, 1.0)
	Utiliy.timeout_ms(mat1.activation_normalization, 2000)
	print("main function")


func function():
	print("another function")
