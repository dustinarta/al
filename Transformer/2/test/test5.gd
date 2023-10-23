@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var vector:int = 64
	var sequence:int = 3
	var head:int = 4
#	var rate:float = 0.01/pow(vector, 2.0)
	var rate:float = 0.001
	var limit:float = 0.1/vector
#	var limit:float = 0.1
	
#	var input:Matrix = Matrix.new().init(sequence, vector, 1.0)
#	var input:Matrix = Matrix.new().init(sequence, vector).self_randomize(-1.0, 1.0)
	var input:Matrix = Matrix.new().init(sequence, vector).init_box_muller(0.5, 0.2)
	var input_t:Matrix = input.transpose()
#	var Q:Matrix = Matrix.new().init(vector, vector, 0.1)
#	var K:Matrix = Matrix.new().init(vector, vector, 0.1)
#	var V:Matrix = Matrix.new().init(vector, vector, 0.1)
	var Q:Matrix = Matrix.new().init(vector, vector, limit)
	var K:Matrix = Matrix.new().init(vector, vector, limit)
	var V:Matrix = Matrix.new().init(vector, vector, limit)
#	var Q:Matrix = Matrix.new().init(vector, vector).self_randomize(-limit, limit)
#	var K:Matrix = Matrix.new().init(vector, vector).self_randomize(-limit, limit)
#	var V:Matrix = Matrix.new().init(vector, vector).self_randomize(-limit, limit)
	
	var weight_mean:float = 1.0/vector
	var weight_deviation:float = 0.01
	
#	var Q:Matrix = Matrix.new().init(vector, vector).init_box_muller(weight_mean, weight_deviation)
#	var K:Matrix = Matrix.new().init(vector, vector).init_box_muller(weight_mean, weight_deviation)
#	var V:Matrix = Matrix.new().init(vector, vector).init_box_muller(weight_mean, weight_deviation)
	
#	input.data[0][1] = 0.1
	var q:Matrix = input.mul(Q)
	var k:Matrix = input.mul(K)
	var v:Matrix = input.mul(V)
	var qs:Array[Matrix] = q.split_col(head)
	var ks:Array[Matrix] = k.split_col(head)
	var vs:Array[Matrix] = v.split_col(head)
	
#	var a:Matrix = q.mul_t(k).softmax()
#	var output:Matrix = a.mul(v)
	var as_:Array[Matrix] = Matrix.multi_softmax(
		Matrix.multi_mul_t(qs, ks)
	)
	var outputs:Array[Matrix] = Matrix.multi_mul(as_, vs)
	var output:Matrix = Matrix.join_col(outputs)
	var expected:Matrix = Matrix.new().init(sequence, vector).self_randomize(-1.0, 1.0)
#	var expected:Matrix = Matrix.new().init(sequence, vector, 1.0)
	var error:Matrix = output.min(expected)
	var errors:Array[Matrix] = error.split_col(head)
	print(error)
#	print(output)
#	var Qs:Array[Matrix] = Q.split_col(head)
#	var Ks:Array[Matrix] = K.split_col(head)
#	var Vs:Array[Matrix] = V.split_col(head)
#	print(Vs)
	var learn_from_v:Matrix
	var learn_from_k:Matrix
	var learn_from_q:Matrix
#	var learn_from_v:Matrix = Matrix.new().init(sequence, 0)
#	var learn_from_k:Matrix = Matrix.new().init(sequence, 0)
#	var learn_from_q:Matrix = Matrix.new().init(sequence, 0)
	var learn:Matrix
#	var learn:Matrix = Matrix.new().init(sequence, vector, 0.0)
#	for i in range(head):
#		learn_from_v = as_[i].transpose().mul(errors[i]).mul_t(Vs[i])
#		learn_from_k = vs[i].mul_t(errors[i]).mul(qs[i]).mul_t(Ks[i])
#		learn_from_q = errors[i].mul_t(vs[i]).mul(ks[i]).mul_t(Qs[i])
#		learn.add_self(learn_from_q.add(learn_from_k).add(learn_from_v))
#
#	learn.mul_self_by_number(0.01)
	var learn_v:Matrix
	var learn_k:Matrix
	var learn_q:Matrix
	var this_learn_array_query:Array[Matrix]
	var this_learn_array_key:Array[Matrix]
	var this_learn_array_value:Array[Matrix]
	this_learn_array_query.resize(head)
	this_learn_array_key.resize(head)
	this_learn_array_value.resize(head)
	var this_learn_query:Matrix = Matrix.new().init(sequence, 0)
	var this_learn_key:Matrix = Matrix.new().init(sequence, 0)
	var this_learn_value:Matrix = Matrix.new().init(sequence, 0)
	for h in range(head):
		var temp_learn_value:Matrix = as_[h]._mul_fast(errors[h], 4)
		var temp_learn_key:Matrix = vs[h]._mul_t_fast(errors[h], 4)._mul_fast(qs[h], 4)
		var temp_learn_query:Matrix = errors[h]._mul_t_fast(vs[h], 4)._mul_fast(ks[h], 4)
		this_learn_array_value[h] = temp_learn_value
		this_learn_array_key[h] = temp_learn_key
		this_learn_array_query[h] = temp_learn_query
#	this_learn_query = Matrix.join_col(this_learn_array_query)
#	this_learn_key = Matrix.join_col(this_learn_array_key)
#	this_learn_value = Matrix.join_col(this_learn_array_value)
#	learn_v = input_t._mul_fast(this_learn_value, 4)
#	learn_k = input_t._mul_fast(this_learn_key, 4)
#	learn_q = input_t._mul_fast(this_learn_query, 4)
#	learn_q.mul_self_by_number(rate)
#	learn_k.mul_self_by_number(rate)
#	learn_v.mul_self_by_number(rate)
	
	
#	print(learn_q)
	
#	Q.min_self(learn_q)
#	K.min_self(learn_k)
#	V.min_self(learn_v)
	for c in range(100):
		q = input.mul(Q)
		k = input.mul(K)
		v = input.mul(V)
		qs = q.split_col(head)
		ks = k.split_col(head)
		vs = v.split_col(head)
		var Qs:Array[Matrix] = Q.split_col(head)
		var Ks:Array[Matrix] = K.split_col(head)
		var Vs:Array[Matrix] = V.split_col(head)
		as_ = Matrix.multi_softmax(
			Matrix.multi_mul_t(qs, ks)
		)
		outputs = Matrix.multi_mul(as_, vs)
		output = Matrix.join_col(outputs)
		error = output.min(expected)
		errors = error.split_col(head)
		if c > 990 or c < 10:
#			print(c, " error ", error)
			pass
		
		learn = Matrix.new().init(sequence, vector)
		for i in range(head):
	#		print(as_[i].transpose().mul(errors[i]).mul_t(Vs[i]))
			learn_from_v = as_[i].transpose().mul(errors[i]).mul_t(Vs[i])
			learn_from_k = vs[i].mul_t(errors[i]).mul(qs[i]).mul_t(Ks[i])
			learn_from_q = errors[i].mul_t(vs[i]).mul(ks[i]).mul_t(Qs[i])
			learn.add_self(learn_from_q.add(learn_from_k).add(learn_from_v))
		learn.mul_self_by_number(rate)
		
		this_learn_array_query = []
		this_learn_array_key = []
		this_learn_array_value = []
		this_learn_array_query.resize(head)
		this_learn_array_key.resize(head)
		this_learn_array_value.resize(head)
		this_learn_query = Matrix.new().init(sequence, 0)
		this_learn_key = Matrix.new().init(sequence, 0)
		this_learn_value = Matrix.new().init(sequence, 0)
		for h in range(head):
			var temp_learn_value:Matrix = as_[h]._mul_fast(errors[h], 4)
			var temp_learn_key:Matrix = vs[h]._mul_t_fast(errors[h], 4)._mul_fast(qs[h], 4)
			var temp_learn_query:Matrix = errors[h]._mul_t_fast(vs[h], 4)._mul_fast(ks[h], 4)
			this_learn_array_value[h] = temp_learn_value
			this_learn_array_key[h] = temp_learn_key
			this_learn_array_query[h] = temp_learn_query
		this_learn_query = Matrix.join_col(this_learn_array_query)
		this_learn_key = Matrix.join_col(this_learn_array_key)
		this_learn_value = Matrix.join_col(this_learn_array_value)
		learn_v = input_t._mul_fast(this_learn_value, 4)
		learn_k = input_t._mul_fast(this_learn_key, 4)
		learn_q = input_t._mul_fast(this_learn_query, 4)
		learn_q.mul_self_by_number(rate)
		learn_k.mul_self_by_number(rate)
		learn_v.mul_self_by_number(rate)
		Q.min_self(learn_q)
		K.min_self(learn_k)
		V.min_self(learn_v)
		
		input.min_self(learn)
	
	
#
	q = input.mul(Q)
	k = input.mul(K)
	v = input.mul(V)
	qs = q.split_col(head)
	ks = k.split_col(head)
	vs = v.split_col(head)
	as_ = Matrix.multi_softmax(
		Matrix.multi_mul_t(qs, ks)
	)
	outputs = Matrix.multi_mul(as_, vs)
	output = Matrix.join_col(outputs)
	error = output.min(expected)
	print(error)
#	print(output)
	
	
#	print(input)



