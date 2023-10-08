@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.new().fill_force(
		[
			[1, 2, 3, 4],
			[5, 6, 7, 8]
		]
	)
	var mat2:Matrix = Matrix.new().fill_force(
		[
			[1, 2, 3, 4],
			[5, 6, 7, 8]
		]
	)
	print(
		Matrix.multi_mul_t(
			mat1.split_col(2), mat2.split_col(2)
		)
	)
