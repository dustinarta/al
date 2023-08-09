@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var only_one = -6.234177179907
	var w:PackedFloat64Array
	w.resize(15)
#	w.fill(-6.234177179907)
	w.fill(-1)
	w[0] = 1
	var mat:Matrix = Matrix.new().fill_force(
		[
			w
		]
	)
	print(mat.softmax())
#	var res
#	res = 0.1 / 14
#	print(res)
#	print(log(0.00714285714286))
