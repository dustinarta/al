@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var vector:int = 4
	var sequence:int = 2
	var head:int = 2
	var rate:float = 0.1/pow(vector, 4.0)
	var input:Matrix = Matrix.new().init(sequence, vector, 1.0)
	var expected:Matrix = Matrix.new().init(sequence, vector, 32)
	
#	var Q:Matrix = Matrix.new().fill_force(
#		[
#			[1, 1, 1, 1],
#			[1, 1, 1, 1],
#			[1, 1, 1, 1],
#			[1, 1, 1, 1]
#		]
#	)
#	var K:Matrix = Matrix.new().fill_force(
#		[
#			[1, 1, 1, 1],
#			[1, 1, 1, 1],
#			[1, 1, 1, 1],
#			[1, 1, 1, 1]
#		]
#	)
#	var V:Matrix = Matrix.new().fill_force(
#		[
#			[-1, 1, 1, 1],
#			[1, 1, 1, 1],
#			[1, 1, 1, 1],
#			[1, 1, 1, 1]
#		]
#	)
	var Q:Matrix = Matrix.new().init(vector, vector, 0.5)
	var K:Matrix = Matrix.new().init(vector, vector, 0.5)
	var V:Matrix = Matrix.new().init(vector, vector, 0.5)
	V.data[0][0] = 0.1
	var q = input.mul(Q)
	var k = input.mul(K)
	var v = input.mul(V)
	var qs = q.split_col(head)
	var ks = k.split_col(head)
	var vs = v.split_col(head)
	var As = Matrix.multi_mul_t(qs, ks)
	var os = Matrix.multi_mul(As, vs)
	var o = Matrix.join_col(os)
	print(o)
	
	var error:Matrix = o.min(expected)
	var errors = error.split_col(head)
	
	var Qs = Q.split_col(head)
	var Ks = K.split_col(head)
	var Vs = V.split_col(head)
	
	var this_learn_array_v:Array[Matrix]
	this_learn_array_v.resize(head)
	var learn_v:Matrix
	
	for h in range(head):
		this_learn_array_v[h] = As[h].mul(errors[h])
#	print(this_learn_array_v)
	learn_v = input.transpose().mul(
		Matrix.join_col(this_learn_array_v)
	)
	learn_v.mul_self_by_number(rate)
	V.min_self(learn_v)
#	print(learn_v)
#	print(V)
#
#	for i in range(100):
##		q = input.mul(Q)
##		k = input.mul(K)
##		v = input.mul(V)
##		qs = q.split_col(head)
##		ks = k.split_col(head)
##		vs = v.split_col(head)
##		As = Matrix.multi_mul_t(qs, ks)
##		os = Matrix.multi_mul(As, vs)
##		o = Matrix.join_col(os)
###		print(o)
##
##		error = o.min(expected)
##		errors = error.split_col(head)
##
##		Qs = Q.split_col(head)
##		Ks = K.split_col(head)
##		Vs = V.split_col(head)
##
##		this_learn_array_v = []
##		this_learn_array_v.resize(head)
##		learn_v
##
##		for h in range(head):
##			this_learn_array_v[h] = As[h].mul(errors[h])
##	#	print(this_learn_array_v)
##		learn_v = input.transpose().mul(
##			Matrix.join_col(this_learn_array_v)
##		)
##		learn_v.mul_self_by_number(rate)
##		V.min_self(learn_v)

	q = input.mul(Q)
	k = input.mul(K)
	v = input.mul(V)
	qs = q.split_col(head)
	ks = k.split_col(head)
	vs = v.split_col(head)
	As = Matrix.multi_mul_t(qs, ks)
	os = Matrix.multi_mul(As, vs)
	o = Matrix.join_col(os)
	print(o)
	print(V)
