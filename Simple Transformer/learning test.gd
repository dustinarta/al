@tool
extends EditorScript


func _run():
	var input:Matrix = Matrix.new()
	input.fill_force(
		[
			[1, -1, 0.5, 0.1],
			[0.1, -0.2, 0.1, 0.5]
		]
	)
	var w:Matrix = Matrix.new()
	w.fill_force(
		[
			[1, -1, 0.5, 0.2],
			[1, -1, 0.5, -0.3],
			[-1, 1, -0.3, 0.5],
			[0.5, 1, -0.1, -0.3]
		]
	)
	w.shufle()
	var s:Matrix = Matrix.new()
	s.fill_force(
		[
			[0.2, 0.8],
			[0.6, 0.4]
		]
	)
	var value = input.mul(w)
	var o:Matrix = s.mul(value)
	var expected:Matrix = Matrix.new()
	expected.fill_force(
		[
			[0.1, 0.1, 0.9, 0.1],
			[0.1, 0.9, 0.1, 0.1]
		]
	)
	var output = calculate(input, w, s)
	print("before\n", output)
#	return
	## learning
	var turn:int = 1000
	for i in range(turn):
		output = calculate(input, w, s)
#		value = input.mul(w)
		var error = output.min(expected)
#		print("error\n", error)
#		var error = expected.min(output)
#		var learn = error.transpose().mul(input)
#		print("here error ", error.mul(s))
#		return
		var learn = input.transpose().mul(s.mul(error))
		w = w.min(learn).mul_self_by_number(0.5)
#	var error = output.min(expected)
#	print( error.transpose().mul(input) )
	value = input.mul(w)
	output = calculate(input, w, s)
	print("after\n", output)
#	print(output.min(expected))

func calculate(input, w, s):
	return s.mul(input.mul(w))
