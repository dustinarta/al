@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.new().init(500, 500).init_random_value(-10.0, 10.0)
	
	var start = Time.get_ticks_usec()
	var mat2 = mat1.inverse().mul(mat1)
	print((Time.get_ticks_usec()-start)/1000000.0)
