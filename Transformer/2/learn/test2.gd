@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.new().fill_force(
		[
			[0.1, 0.2]
		]
	)
	
	var mat2:Matrix = Matrix.new().fill_force(
		[
			[0.8, 0.2, 0.3],
			[0.5, 0.1, 0.4]
		]
	)
	
	var mat3:Matrix = Matrix.new().fill_force(
		[
			[0.2, -0.2, 0.3],
			[0.5, 0.1, -0.4]
		]
	)
#	mat1.self_randomize(-0.5, 0.5)
	
	var expected:Matrix = Matrix.new().fill_force(
		[
			[0.01]
		]
	)
	
	var result
	var learn
	var error
	result = mat1.mul(mat2).mul_t(mat3).mul_t(mat1)
	print(result)
	
	## mat2 learn
#	for i in range(100):
#		result = mat1.mul(mat2).mul_t(mat3).mul_t(mat1)
#		error = result.min(expected)
#		learn = mat1.transpose().mul(error).mul(mat1).mul(mat3)#.mul_self_by_number(0.1)
#		mat2.min_self(learn)
	
	## mat3 learn
#	for i in range(100):
#		result = mat1.mul(mat2).mul_t(mat3).mul_t(mat1)
#		error = result.min(expected)
#		learn = mat1.transpose().mul_t(error).mul(mat1).mul(mat2)#.mul_self_by_number(0.1)
#		mat3.min_self(learn)
	
	## mat1 learn
	for i in range(100):
		result = mat1.mul(mat2).mul_t(mat3).mul_t(mat1)
		error = result.min(expected)
		learn = error.transpose().mul(mat1).mul(mat2).mul_t(mat3)
		mat1.min_self(learn)
		learn = error.mul(mat1).mul(mat3).mul_t(mat2)
		mat1.min_self(learn)
		
#
	
	result = mat1.mul(mat2).mul_t(mat3).mul_t(mat1)
	print(result)
