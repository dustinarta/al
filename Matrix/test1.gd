@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.new().init(2, 3)
	mat1.fill(
		[
			[1, 2, 3],
			[4, 5, 6]
		]
	)
	var mat2:Matrix = Matrix.new().init(3, 2)
	mat2.fill(
		[
			[1, 2],
			[3, 4],
			[5, 6]
		]
	)
	var mat3:Matrix = Matrix.new().init(3, 3)
	mat3.fill(
		[
			[1, 2, 3],
			[4, 5, 6],
			[7, 8, 9]
		]
	)
#	print(mat1.mul(mat2))
	print(mat3.determinan())
