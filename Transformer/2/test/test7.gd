@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sequence:int = 3
	var vector:int = 512
	var input:Matrix = Matrix.new().init(sequence, vector).init_box_muller(1.0, 0.3)
	var weight:Matrix = Matrix.new().init(vector, vector).init_box_muller(
		1.0/vector, 1.0/vector
	)
	var result = input.mul(weight)
#	print(result)
	print(result.mul_t(result))
#	print(result.mul_t(result).mul(result))
