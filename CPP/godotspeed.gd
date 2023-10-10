@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.new().init(10000, 1000)
	mat1.self_randomize()
	var mat2:Matrix = mat1.self_randomize()
	
	var start = Time.get_ticks_usec()
	var result = mat1.add_self(mat2)
	print((Time.get_ticks_usec()-start)/1000000.0)
	
