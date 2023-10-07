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
			[0.8],
			[0.5]
		]
	)
#	mat1.self_randomize(-0.5, 0.5)
	
	var expected:Matrix = Matrix.new().fill_force(
		[
			[0.1, 0.1]
		]
	)
	
	var result
	var learn
	var error
	result = mat1.mul(mat2).mul(mat1)
	print(result)
	
	## mat2 learn
#	for i in range(10000):
#		result = mat1.mul(mat2).mul(mat1)
#		error = result.min(expected)
#		learn = mat1.transpose().mul(error).mul_t(mat1)#.mul_self_by_number(0.1)
#		mat2.min_self(learn)
	
	## mat1 learn
	for i in range(1):
		result = mat1.mul(mat2).mul(mat1)
		error = result.min(expected)
#		learn = error#.mul(mat2).mul_t(mat2)
#		learn = mat2.transpose().mul(mat2).mul(error)
		learn = error.mul_t(mat1).mul_t(mat2)
#		learn = mat2.transpose().mul_t(mat1).mul(error)
		mat1.min_self(learn)
		
	
	result = mat1.mul(mat2).mul(mat1)
	print(result)
