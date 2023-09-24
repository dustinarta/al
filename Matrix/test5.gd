@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.new().fill_force(
		[
			[1, 2],
			[2, 5],
			[9, 3],
			[0, 1]
		]
	)
	var mat2:Matrix = Matrix.new().fill_force(
		[
			[1, 2, 3, 4],
			[2, 5, 1, 7]
		]
	)
	var result
	result = mat1.mul(mat2)
	print(result.batch_normalization())
