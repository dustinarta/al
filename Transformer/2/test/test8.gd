@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var input:Matrix = Matrix.new().fill_force(
		[
			[1, 1],
			[1, 1]
		]
	)
	var weight:Matrix = Matrix.new().fill_force(
		[
			[1, 2],
			[3, 4]
		]
	)
	print(input.mul(weight))
