@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var originalmatrix:Matrix = Matrix.new().init(2, 4).init_random_value(-2.0, 2.0).self_resquare_diagonal()
#	print(originalmatrix)
	var inv1 = originalmatrix.inverse()
	var inv2 = originalmatrix.inverse_custom(2)
	
#	print(inv1)
#	print(inv2)
#	print(originalmatrix)
