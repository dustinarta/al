@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.new()
	mat1.fill_force(
		[
			[0.1, 0.2],
			[0.3, 0.1],
			[-0.2, 0.5]
		]
	)
	var mat2:Matrix = Matrix.new()
	mat2.fill_force(
		[
			[0.1, 0.1, 0.2, -0.1],
			[0.3, 0.1, -0.3, 0.2]
		]
	)
	var end:Matrix = Matrix.new()
	end.fill_force(
		[
			[0.1, 0.1, 0.9, 0.1],
			[0.1, 0.9, 0.1, 0.1],
			[0.9, 0.1, 0.1, 0.1]
		]
	)
	
	var result = mat1.mul(mat2)
	var error = result.min(end)
	var learn = mat1.transpose().mul(error)
#	print(mat1)
#	print(result)
#	return
	var start = Time.get_ticks_usec()
	for i in range(10000):
		result = mat1.mul(mat2)
		error = result.min(end)
		learn = mat1.transpose().mul(error)
		mat2 = mat2.min(learn.mul_self_by_number(1))
	
	print("Matrix time ", (Time.get_ticks_usec() - float(start))/1000000)
	result = mat1.mul(mat2)
#	print(mat1)
	print(result)
	
