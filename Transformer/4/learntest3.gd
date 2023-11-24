@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var vector:int = 1024
	var sequence:int = 4
	var head:int = 1
	var rate:float = 0.001/pow(vector, 2.0)
#	var input:Matrix = Matrix.new().init(sequence, vector, 1.0)
	var expected:Matrix = Matrix.new().init(sequence, vector, 256)
	var input:Matrix = Matrix.new().init(sequence, vector).init_random_value(-1.0, 1.0)
#	var expected:Matrix = Matrix.new().init(sequence, vector).init_random_value(-1.0, 1.0)
	
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
#			[-1, 1, 1, 1],
#			[1, 1, 1, 1],
#			[1, 1, 1, 1],
#			[1, 1, 1, 1]
#		]
#	)
#	var V:Matrix = Matrix.new().fill_force(
#		[
#			[1, 1, 1, 1],
#			[1, 1, 1, 1],
#			[1, 1, 1, 1],
#			[1, 1, 1, 1]
#		]
#	)
	var init_weight_range:float = 2.0/vector
	var Q:Matrix = Matrix.new().init(vector, vector).init_random_value(-init_weight_range, init_weight_range)
	var K:Matrix = Matrix.new().init(vector, vector).init_random_value(-init_weight_range, init_weight_range)
	var V:Matrix = Matrix.new().init(vector, vector).init_random_value(-init_weight_range, init_weight_range)
#	V.data[0][0] = 0.1
	var q = input.mul(Q)
	var k = input.mul(K)
	var v = input.mul(V)
	var qs = q.split_col(head)
	var ks = k.split_col(head)
	var vs = v.split_col(head)
	var As = Matrix.multi_mul_t(qs, ks)
	var os = Matrix.multi_mul(As, vs)
	var o = Matrix.join_col(os)
#	print(As)
#	print(o)
	print("output first 10 row ", o.data[0].slice(0, 10), "\n")
#	return
	var error:Matrix = o.min(expected)
	var errors = error.split_col(head)
#	print(error)
	var Qs = Q.split_col(head)
	var Ks = K.split_col(head)
	var Vs = V.split_col(head)
	
	var this_learn_array_q:Array[Matrix]
	var this_learn_array_k:Array[Matrix]
	var this_learn_array_v:Array[Matrix]
	this_learn_array_q.resize(head)
	this_learn_array_k.resize(head)
	this_learn_array_v.resize(head)
	var learn_q:Matrix
	var learn_k:Matrix
	var learn_v:Matrix
	
	for h in range(head):
		this_learn_array_v[h] = As[h].mul(errors[h])
		this_learn_array_k[h] = vs[h].mul_t(errors[h]).mul(qs[h])
		this_learn_array_q[h] = errors[h].mul_t(vs[h]).mul(ks[h])
	learn_v = input.transpose().mul(
		Matrix.join_col(this_learn_array_v)
	)
	learn_k = input.transpose().mul(
		Matrix.join_col(this_learn_array_k)
	)
	learn_q = input.transpose().mul(
		Matrix.join_col(this_learn_array_q)
	)
	learn_q.mul_self_by_number(rate)
	learn_k.mul_self_by_number(rate)
	learn_v.mul_self_by_number(rate)
#	print("learn_q ", learn_q, "\n")
#	print("learn_k ", learn_k, "\n")
#	print("learn_v ", learn_v, "\n")
	Q.min_self(learn_q)
	K.min_self(learn_k)
	V.min_self(learn_v)
	
#	print("return on learn")
#	return
	
#
#	for i in range(3):
#		q = input.mul(Q)
#		k = input.mul(K)
#		v = input.mul(V)
#		qs = q.split_col(head)
#		ks = k.split_col(head)
#		vs = v.split_col(head)
#		As = Matrix.multi_mul_t(qs, ks)
#		os = Matrix.multi_mul(As, vs)
#		o = Matrix.join_col(os)
##		print(o)
#
#		error = o.min(expected)
#		errors = error.split_col(head)
#
#		Qs = Q.split_col(head)
#		Ks = K.split_col(head)
#		Vs = V.split_col(head)
#
#		this_learn_array_v = []
#		this_learn_array_v.resize(head)
#		learn_v
#
#		for h in range(head):
#			this_learn_array_v[h] = As[h].mul(errors[h])
#			this_learn_array_k[h] = vs[h].mul_t(errors[h]).mul(qs[h])
#			this_learn_array_q[h] = errors[h].mul_t(vs[h]).mul(ks[h])
#		learn_v = input.transpose().mul(
#			Matrix.join_col(this_learn_array_v)
#		)
#		learn_k = input.transpose().mul(
#			Matrix.join_col(this_learn_array_k)
#		)
#		learn_q = input.transpose().mul(
#			Matrix.join_col(this_learn_array_q)
#		)
#		learn_q.mul_self_by_number(rate)
#		learn_k.mul_self_by_number(rate)
#		learn_v.mul_self_by_number(rate)
#		Q.min_self(learn_q)
#		K.min_self(learn_k)
#		V.min_self(learn_v)
#
	q = input.mul(Q)
	k = input.mul(K)
	v = input.mul(V)
	qs = q.split_col(head)
	ks = k.split_col(head)
	vs = v.split_col(head)
	As = Matrix.multi_mul_t(qs, ks)
	os = Matrix.multi_mul(As, vs)
	o = Matrix.join_col(os)
	error = o.min(expected)
	
	print("output first 10 row ", o.data[0].slice(0, 10), "\n")
#	print(o)
#	print(error)
#	print(V)
