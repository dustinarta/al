@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var vector:int = 4
	var sequence:int = 3
	
	var input:Matrix = Matrix.new().init(sequence, vector, 1.0)
	var Q:Matrix = Matrix.new().init(vector, vector, 0.5)
	var K:Matrix = Matrix.new().init(vector, vector, 0.5)
	var V:Matrix = Matrix.new().init(vector, vector, 0.5)
	
	input.data[0][1] = 0.1
	
	var q:Matrix = input.mul(Q)
	var k:Matrix = input.mul(K)
	var v:Matrix = input.mul(V)
	
	var a:Matrix = q.mul_t(k).softmax()
#	print(a)
	var output:Matrix = a.mul(v)
	var expected:Matrix = Matrix.new().init(sequence, vector, 2)
	var error:Matrix = output.min(expected)
	
	var learn_from_v = a.transpose().mul(error).mul_t(V)
	var learn_from_k = v.mul_t(error).mul(q).mul_t(K)
	var learn_from_q = error.mul_t(v).mul(k).mul_t(Q)
	
	var learn = learn_from_q.add(learn_from_k).add(learn_from_v)
	learn.mul_self_by_number(0.01)
	print(learn)
#	print(error)
#	print(input)
	print(output)
	
	
	for i in range(10000):
		q = input.mul(Q)
		k = input.mul(K)
		v = input.mul(V)
		a = q.mul_t(k).softmax()
		output = a.mul(v)
		error = output.min(expected)
		
		learn_from_v = a.transpose().mul(error).mul_t(V)
		learn_from_k = v.mul_t(error).mul(q).mul_t(K)
		learn_from_q = error.mul_t(v).mul(k).mul_t(Q)
		learn = learn_from_q.add(learn_from_k).add(learn_from_v)
		learn.mul_self_by_number(0.1/pow(vector, 2.5))
		
		input.min_self(learn)
	
	q = input.mul(Q)
	k = input.mul(K)
	v = input.mul(V)
	a = q.mul_t(k).softmax()
	output = a.mul(v)
	
#	print(input)
	print(output)



