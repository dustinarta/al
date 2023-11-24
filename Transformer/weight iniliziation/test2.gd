@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var vector:int = 4
	var sequence:int = 4
	
#	var input = Matrix.new().init(sequence, vector).init_random_value(-2.0, 2.0)
	var input = Matrix.new().fill_force(
		[
			[1, 2, 3, 4],
			[2, 3, 4, 1],
			[3, 4, 1, 2],
			[4, 1, 2, 3]
		]
	)
	
#	print(input.determinan2())
#	print(input.adjoint())
	print(input.inverse())
#	print(input)
#	print(input.inverse().mul(input.mul(input)))
	
