tool
extends EditorScript


func _run():
	var mat1 = Matrix.new([2, 3])
	mat1.fill([2, 4, 3, 5, 6, 1])
	var mat2 = Matrix.new([2, 3])
	mat2.fill([4, 3, 5, 6, 7, 4])
	print(mat1.add(mat2))
