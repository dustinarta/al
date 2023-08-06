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
	print( mat1.mul(mat2).transpose() )
	print( mat2.transpose().mul_t(mat1) )
	return
	var mat3 = mat1.mul(mat2)
#	print(mat3)
#	return
	var mat4:Matrix = Matrix.new()
	mat4.fill_force(
		[
			[0.1, 0.2, 0.3]
		]
	)
	var end:Matrix = Matrix.new()
	end.fill_force(
		[
			[0.5, 0.5, 0.5, 0.5]
		]
	)
	
	var result = mat4.mul(mat3)
#	print(result)
#	return
	var error = result.min(end)
	var learn = error.mul_t(mat2).mul_t(mat1)
#	print(learn)
	for i in range(1000):
		mat3 = mat1.mul(mat2)
		result = mat4.mul(mat3)
		error = result.min(end)
		learn = error.mul_t(mat2).mul_t(mat1)
		mat4 = mat4.min(learn.div_self_by_number(0.1))
	mat3 = mat1.mul(mat2)
	result = mat4.mul(mat3)
#	print(result)
