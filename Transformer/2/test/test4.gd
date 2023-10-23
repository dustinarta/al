@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var vector:int = 64
	var sequence:int = 3
	var head:int = 2
	
	var input:Matrix = Matrix.new().init(sequence, vector).self_randomize(-1.0, 1.0)
	var Q:Matrix = Matrix.new().init(vector, vector, 1.0/vector)
	var K:Matrix = Matrix.new().init(vector, vector, 1.0/vector)
	var V:Matrix = Matrix.new().init(vector, vector, 1.0/vector)
	
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
	var expected:Matrix = Matrix.new().init(sequence, vector, 2)
	var error:Matrix = output.min(expected)
	var errors:Array[Matrix] = error.split_col(head)
	print(output)
	var Qs:Array[Matrix] = Q.split_col(head)
	var Ks:Array[Matrix] = K.split_col(head)
	var Vs:Array[Matrix] = V.split_col(head)
#	print(Vs)
#	var learn_from_v:Matrix = Matrix.new().init(sequence, 0)
#	var learn_from_k:Matrix = Matrix.new().init(sequence, 0)
#	var learn_from_q:Matrix = Matrix.new().init(sequence, 0)
	var learn_from_v:Matrix
	var learn_from_k:Matrix
	var learn_from_q:Matrix
	var learn:Matrix = Matrix.new().init(sequence, vector, 0.0)
	for i in range(head):
		learn_from_v = as_[i].transpose().mul(errors[i]).mul_t(Vs[i])
		learn_from_k = vs[i].mul_t(errors[i]).mul(qs[i]).mul_t(Ks[i])
		learn_from_q = errors[i].mul_t(vs[i]).mul(ks[i]).mul_t(Qs[i])
		learn.add_self(learn_from_q.add(learn_from_k).add(learn_from_v))
	
	learn.mul_self_by_number(0.01)
#	print(learn)
#	print(learn)
#	print(error)
#	print(input)
#	print(output)
	

	for c in range(1000):
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
		errors = error.split_col(head)
		if c > 990 or c < 10:
#			print(c, " error ", error)
			pass
		learn_from_v
		learn_from_k
		learn_from_q
		learn = Matrix.new().init(sequence, vector)
		for i in range(head):
	#		print(as_[i].transpose().mul(errors[i]).mul_t(Vs[i]))
			learn_from_v = as_[i].transpose().mul(errors[i]).mul_t(Vs[i])
			learn_from_k = vs[i].mul_t(errors[i]).mul(qs[i]).mul_t(Ks[i])
			learn_from_q = errors[i].mul_t(vs[i]).mul(ks[i]).mul_t(Qs[i])
			learn.add_self(learn_from_q.add(learn_from_k).add(learn_from_v))
		learn.mul_self_by_number(0.1/pow(vector, 2.0))
		if c > 990 or c < 10:
#			print(c, " learn ", learn)
			pass
		input.min_self(learn)
	
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
	
	
	
#	print(input)
	print(output)



