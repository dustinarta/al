@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sequence = 4
	var vector = 8
	var mat1:Matrix = Matrix.new().init(sequence, vector).self_randomize(-1.0, 1.0)
	var mat2:Matrix = Matrix.new().init(vector, vector).self_randomize(-1.0, 1.0)
	var mat3:Matrix = Matrix.new().init(sequence, vector).self_randomize(-1.0, 1.0)
	
	var result = mat1.mul(mat2)
	var error = result.min(mat3)
	var learn = error.mul_t(mat2)
	print(error)
	
	for i in range(10000):
		result = mat1.mul(mat2)
		error = result.min(mat3)
		learn = error.mul_t(mat2).mul_self_by_number(0.001)
		mat1.min_self(learn)
	
	result = mat1.mul(mat2)
	error = result.min(mat3)
	learn = error.mul_t(mat2)
	print(error)
	
