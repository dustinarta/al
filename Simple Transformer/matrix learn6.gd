@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var mat1:Matrix = Matrix.new()
	mat1.fill_force(
		[
			[0.1, 1]
		]
	)
	var mat2:Matrix = Matrix.new()
	mat2.fill_force(
		[
			[0.1, -0.1, -0.3],
			[0.3, 0.2, 0.1]
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
	var end:Matrix = Matrix.new()
	end.fill_force(
		[
			[0.4, 0.1, -0.1, -0.2]
		]
	)
	var s = mat1.mul(mat2).softmax()
	var result = s.mul(mat3)
	var s_d = s.derivative_softmax()
	var error = result.min(end)
	var learn = error.mul_t(mat3).mul2(s_d).mul_t(mat2)
	print(learn)
	return
#	print(learn)
	print(result)
	for i in range(10000):
		s = mat1.mul(mat2).softmax()
		s_d = s.derivative_softmax()
		result = s.mul(mat3)
		error = result.min(end)
		learn = mat1.transpose().mul(error.mul_t(mat3).mul2(s_d))
#		print("###############")
#		print(result)
#		print(error)
#		print("###############")
		mat2 = mat2.min(learn)
	
	result = mat1.mul(mat2).softmax().mul(mat3)
	print(result)
