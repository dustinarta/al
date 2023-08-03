@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var input:Matrix = Matrix.new()
	input.fill_force(
		[
			[1, 2, 3, 4],
			[4, 3, 2, 1]
		]
	)
	var wV:Matrix = Matrix.new()
	wV.fill_force(
		[
			[6, 7, 8, 9],
			[-INF, 8, 7, 6],
			[1, 2, 3, 4],
			[4, 3, 2, 1]
		]
	)
	
#	print(input.mul(wV))
	
	var mat1:Matrix = Matrix.new()
	mat1.fill_force(
		[
			[6, 7],
			[9, 8]
		]
	)
	
	
	var mat3:Matrix = Matrix.new()
	mat3.fill_force(
		[
			[6, 7, 8],
			[9, 10, 11],
			[12, 13, 14],
			[15, 16, 17]
		]
	)
	
	var mat2:Matrix = Matrix.new()
	mat2.fill_force(
		[
			[-INF, 6, 8, 9],
			[-INF, 9, 7, 6]
		]
	)
	
	print(mat2.mul(mat3))
