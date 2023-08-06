@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.new()
	mat1.fill_force(
		[
			[0.1, -0.2]
		]
	)
	var mat2:Matrix = Matrix.new()
	mat2.fill_force(
		[
			[0.1, -0.1],
			[0.3, 0.1],
			[-0.3, 0.2]
		]
	)
	var mat3:Matrix = Matrix.new()
	mat3.fill_force(
		[
			[0.4, -0.4, 0.2, -0.5],
			[0.3, 0.9, -0.2, -0.4],
			[0.4, -0.3, -0.3, 0.3]
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
			[0.2, -0.2, 0.2, 0.5, 0.1]
		]
	)
	var s = mat1.mul_t(mat2).mul(mat3).softmax()
	var result = s.mul(mat4)
	var s_d = s.derivative_softmax()
	var error = result.min(end)
	var learn = error.mul_t(mat4).mul2(s_d).mul_t(mat3).transpose().mul(mat1)
#	var learn = error.mul_t(mat4)
	print(learn)
#	print( mat3.transpose().mul(mat2).mul_t(mat1).transpose().softmax().mul(mat4) )
	
#	for i in range(1000):
#		s = mat1.mul(mat2).softmax()
#		s_d = s.derivative_softmax()
#		result = s
#
##		error = result.min(end)
##		learn = error.mul2(s_d).mul_t(mat2)
#
#		error = s_d.min(end)
#		learn = error.mul_t(mat2)
#
#		mat1 = mat1.min(learn)
#
#	result = mat1.mul(mat2).softmax()
#	print(result)
	
