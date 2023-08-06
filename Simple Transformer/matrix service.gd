@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.new()
	mat1.fill_force(
		[
			[0.1, 0.2]
		]
	)
	var mat2:Matrix = Matrix.new()
	mat2.fill_force(
		[
			[0.1, 0.1, 0.2],
			[0.3, 0.1, -0.3]
		]
	)
	var mat3:Matrix = Matrix.new()
	mat3.fill_force(
		[
			[0.1, 0.1, 0.2, 0.1],
			[0.3, 0.1, -0.3, -0.2],
			[0.1, -0.2, -0.3, 0.3]
		]
	)
	var mat4:Matrix = Matrix.new()
	mat4.fill_force(
		[
			[0.1, 0.1, 0.2, 0.1, -0.3],
			[0.3, 0.1, -0.3, -0.2, 0.1],
			[0.1, -0.2, -0.3, 0.3, 0.9],
			[0.3, -0.3, -0.2, 0.1, -0.1]
		]
	)
	var end:Matrix = Matrix.new()
	end.fill_force(
		[
			[0.1, 0.1, 0.9, 0.1, 7]
		]
	)
	var result = mat1.mul(mat2).mul(mat3).mul(mat4)
	var error = result.min(end)
	var learn = error.mul_t(mat4).mul_t(mat3).mul_t(mat2)
#	print(learn)
	for i in range(7):
		result = mat1.mul(mat2).mul(mat3).mul(mat4)
		error = result.min(end)
		learn = error.mul_t(mat4).mul_t(mat3).mul_t(mat2)
		mat1.min_self(learn.div_self_by_number(10))
		
		result = mat1.mul(mat2).mul(mat3).mul(mat4)
		error = result.min(end)
		learn = mat1.transpose().mul(error).mul_t(mat4).mul_t(mat3)
		mat2.min_self(learn.div_self_by_number(10))
		
		result = mat1.mul(mat2).mul(mat3).mul(mat4)
		error = result.min(end)
		learn = mat2.transpose().mul_t(mat1).mul(error).mul_t(mat4)
		mat3.min_self(learn.div_self_by_number(10))
		
		result = mat1.mul(mat2).mul(mat3).mul(mat4)
		error = result.min(end)
		learn = mat3.transpose().mul_t(mat2).mul_t(mat1).mul(error)
		mat4.min_self(learn.div_self_by_number(10))
		
	result = mat1.mul(mat2).mul(mat3).mul(mat4)
	print(mat1)
	print(mat2)
	print(mat3)
	print(mat4)
	print(result)
