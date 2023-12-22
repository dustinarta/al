@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var originalmatrix:Matrix = Matrix.new().init(2, 128).init_random_value(-2.0, 2.0).self_resquare_diagonal()
#	print(originalmatrix)
	var start = Time.get_ticks_usec()
	var inv1 = originalmatrix.inverse()
	print(float(Time.get_ticks_usec()-start)/1000000.0)
	start = Time.get_ticks_usec()
#	var inv2 = originalmatrix.inverse_custom(2)
	var inv2 = originalmatrix.inverse2()
	print(float(Time.get_ticks_usec()-start)/1000000.0)
#	print(inv1)
#	print(inv2)
#	print(inv1.min(inv2))
#	print(originalmatrix)
