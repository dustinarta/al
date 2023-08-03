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
	var mat3 = mat1.mul(mat2)
	var mat4:Matrix = Matrix.new()
	mat4.fill_force(
		[
			[0.1],
			[0.2],
			[0.3],
			[0.4]
		]
	)
	var end:Matrix = Matrix.new()
	end.fill_force(
		[
			[0.5],
			[0.5],
			[0.5]
		]
	)
	
	var result = mat3.mul(mat4)
#	print(result)
#	return
	var error = result.min(end)
	var learn = mat1.transpose().mul( error.mul_t(mat4) )
#	mat4.mul_t(error).mul(mat1)
#	error.mul_t(mat4).mul_t(mat2)
#	print(learn)
#	for i in range(100):
#		mat3 = mat1.mul(mat2)
#		result = mat3.mul(mat4)
#		error = result.min(end)
#		learn = mat1.transpose().mul( error.mul_t(mat4) )
#		mat2 = mat2.min(learn.div_self_by_number(0.1))
#	mat3 = mat1.mul(mat2)
#	result = mat3.mul(mat4)
#	print(result)
#	mat3 = mat1.mul(mat2)
#	error = result.min(end)
#	learn = mat3.transpose().mul(error)
#	print(learn)
	
	for i in range(100):
		mat3 = mat1.mul(mat2)
		result = mat3.mul(mat4)
		error = result.min(end)
		learn = mat3.transpose().mul(error)
		mat4 = mat4.min(learn.div_self_by_number(0.1))
	mat3 = mat1.mul(mat2)
	result = mat3.mul(mat4)
	print(result)
	
