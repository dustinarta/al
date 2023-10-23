@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var input:Matrix = Matrix.new().init(1, 3).fill_force(
		[
			[1, 2]
		]
	)
	var weight:Matrix = Matrix.new().fill_force(
		[
			[2, 2],
			[2, 2]
		]
	)
	var expected:Matrix = Matrix.new().fill_force(
		[
			[4, 4]
		]
	)
	var output:Matrix = input.mul(weight)
	print(output)
	
