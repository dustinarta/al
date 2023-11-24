@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var vector = 256
	var sequence = 50
	var input:Matrix = Matrix.new().init(sequence, vector).init_random_value(-2.0, 2.0)
	input.self_resquare_diagonal(1.0)
	var expected:Matrix = Matrix.new().init(sequence, vector).init_random_value(-1.0, 1.0)
	expected.self_resquare_diagonal(1.0)
	var start = Time.get_ticks_usec()
	var weight = input.inverse_custom(vector-sequence)._mul_fast(expected, 4)
#	var weight = input.inverse()._mul_fast(expected, 4)
	
	input.self_pop_row(sequence)
	expected.self_pop_row(sequence)
#	print(input.mul(weight))
#	print(expected)
#	print("time = ", float(Time.get_ticks_usec()-start)/1000000.0)
#	print(input._mul_fast(weight, 4).min(expected).data[0])
	
#	print(weight)
#	print(
#		Matrix.new().init(4, 4).self_assign_m(
#			Matrix.new().init(2, 4).init_random_value(-1, 1)
#		)
#	)
