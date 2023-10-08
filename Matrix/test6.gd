@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat:Matrix = Matrix.new().fill_force(
		[
			[1, 2, 3, 4],
			[5, 6, 7, 8]
		]
	)
	var result
	result = mat
	print(mat)
	result = mat.split_col(3)
	print(result)
	result = Matrix.join_col(result)
	print(result)
