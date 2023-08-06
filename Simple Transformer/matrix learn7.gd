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
			[0.1, -0.1, -0.3],
			[0.3, 0.1, 0.2]
		]
	)
#	var mat3:Matrix = Matrix.new()
#	mat3.fill_force(
#		[
#			[1, 0],
#			[0, 1]
#		]
#	)
	var end:Matrix = Matrix.new()
	end.fill_force(
		[
			[0, 0, 1]
		]
	)
	var s = mat1.mul(mat2).softmax()
	var result = s
	var s_d = s.derivative_softmax()
	var error = result.min(end)
	var learn = error.mul2(s_d).mul_t(mat2)
	print(learn)
	
	
	for i in range(1000):
		s = mat1.mul(mat2).softmax()
		s_d = s.derivative_softmax()
		result = s
		
#		error = result.min(end)
#		learn = error.mul2(s_d).mul_t(mat2)
		
		error = s_d.min(end)
		learn = error.mul_t(mat2)
		
		mat1 = mat1.min(learn)
		
	result = mat1.mul(mat2).softmax()
	print(result)
	
