@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.new()
	mat1.fill_force(
		[
			[1.0, 2.0],
			[3.0, 4.0],
			[5.0, 6.0]
		]
	)
	#row_size = 3
	#col_size = 2
	
	var mat2:Matrix = Matrix.new()
	mat2.fill_force(
		[
			[1.0, 2.0, 3.0],
			[4.0, 5.0, 6.0]
		]
	)
	#row_size = 2
	#col_size = 3
	
	var mat3:Matrix = mat1.mul(mat2)
	#valid if mat1.col_size is mat2.row_size
	#row_size = mat1.row_size
	#col_size = mat2.col_size
	
	
