@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.create(
		[
			[1, 2],
			[3, 4],
			[5, 6]
		]
	)
	var mat2:Matrix = Matrix.create(
		[
			[1, 2],
			[3, 4],
			[5, 6]
		]
	)
	print(mat1.mul(mat2.transpose()))
	print(mat1.mul_t(mat2))
	print(Matrix._mul(mat1, mat2.transpose(), 0, 3/2))
	print(Matrix._mul(mat1, mat2.transpose(), 3/2, 3))
