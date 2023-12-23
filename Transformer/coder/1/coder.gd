extends RefCounted
class_name Coder

var Query:Matrix
var Key:Matrix
var Value:Matrix

var Sequence_length:int
var Vector_size:int

var _result:Array

func init(vector_size:int):
	Vector_size = vector_size
	var num_range:float = 1.0/Vector_size
	Query = Matrix.new().init(vector_size, vector_size).self_randomize(-num_range, num_range)
	Key = Matrix.new().init(vector_size, vector_size).self_randomize(-num_range, num_range)
	Value = Matrix.new().init(vector_size, vector_size).self_randomize(-num_range, num_range)
	return self

static func init_from_dict(data:Dictionary)->Coder:
	var coder:Coder = Coder.new()
	coder.Vector_size = data["vector_size"]
	coder.Query = Matrix.new().load_from_dict(data["query"])
	coder.Key = Matrix.new().load_from_dict(data["key"])
	coder.Value = Matrix.new().load_from_dict(data["value"])
	return coder

func forward_fast(input:Matrix):
	if input.col_size != Vector_size:
		printerr("Invalid vector size!")
		return null
	_result.clear()
	_result.resize(6)
	var query = input._mul_fast(Query, 2)
	var key = input._mul_fast(Key, 2)
	var value = input._mul_fast(Value, 2)
	_result[0] = input#.duplicate()
	_result[1] = query#.duplicate()
	_result[2] = key#.duplicate()
	_result[3] = value#.duplicate()
	var attention = query._mul_t_fast(key, 2).div_self_by_number(sqrt(Vector_size)).softmax()
	_result[4] = attention#.duplicate()
	var output = attention._mul_fast(value, 2).activation_normalization()
	_result[5] = output.add_self(input)#.duplicate()
#		print("Query result", _result[1], "\n")
#		print("Key result", _result[2], "\n")
#		print("Value result", _result[3], "\n")
#		print("Attention result", _result[4], "\n")
#		print("Output result", _result[5], "\n")
	return output

func forward(input:Matrix):
	if input.col_size != Vector_size:
		printerr("Invalid vector size!")
		return null
	_result.clear()
	_result.resize(6)
	var query = input.mul(Query)
	var key = input.mul(Key)
	var value = input.mul(Value)
	_result[0] = input#.duplicate()
	_result[1] = query#.duplicate()
	_result[2] = key#.duplicate()
	_result[3] = value#.duplicate()
	var attention = query.mul_t(key).div_self_by_number(sqrt(Vector_size)).softmax()
	_result[4] = attention#.duplicate()
	var output = attention.mul(value).activation_normalization()
	_result[5] = output.add_self(input)#.duplicate()
#		print("Query result", _result[1], "\n")
#		print("Key result", _result[2], "\n")
#		print("Value result", _result[3], "\n")
#		print("Attention result", _result[4], "\n")
#		print("Output result", _result[5], "\n")
	return output

func forward2(input1:Matrix, input2:Matrix):
	if input1.col_size != Vector_size and input2.col_size != Vector_size:
		printerr("Invalid vector size!")
		return null
	
	var query = input1.mul(Query)
	var key = input2.mul(Key)
	var value = input2.mul(Value)
	
	return query.mul_t(key).div_self_by_number(sqrt(Vector_size)).softmax().mul(value).activation_normalization()

func learn(error:Matrix, rate:float = 0.0001):
	## A x i x v -> Ti x TA x e
	## Q x Tk x Ti x V
	## TV x i x k x TQ -> Ti x V x e x Q
	## i x Q x TK x V -> Ti x e x TV x K
	var _fast_result0:Matrix = _result[0].transpose()
	var learn_value:Matrix = _fast_result0._mul_t_fast(_result[4], 2)._mul_fast(error, 2)
	learn_value.mul_self_by_number(rate)
	Value.min_self(learn_value)
#		print("Value learn ", learn_value)
	
	
	var learn_key:Matrix = _fast_result0._mul_fast(_result[3], 2)._mul_t_fast(error, 2)._mul_fast(_result[1], 2)
#		print("Key learn ", learn_value)
	learn_key.mul_self_by_number(rate)
	Key.min_self(learn_key)
	
	var learn_query:Matrix = _fast_result0._mul_fast(error, 2)._mul_t_fast(_result[3], 2)._mul_fast(_result[2], 2)
	learn_query.mul_self_by_number(rate)
	Query.min_self(learn_query)
#		print("Query learn ", learn_value)
	
	
	var next_learn:Matrix
#		next_learn = error.mul_t(Value).mul(Key).mul_t(Query)
	next_learn = _result[4].transpose().mul(error).mul_t(Value)
	next_learn.add_self(_result[3].mul_t(error).mul(_result[1]).mul_t(Key))
	next_learn.add_self(error.mul_t(_result[3]).mul(_result[2]).mul_t(Query))
#		print(_result[3].mul_t(error).mul(_result[1]).mul_t(Key))
	next_learn.mul_self_by_number(1.0/3.0)
#		print("error ", error)
#		print("Value ", Value)
#		print("next learn ", next_learn)
#		print(next_learn, "\n")
	return next_learn

func learn2(errors:Array, rate:float = 0.0001):
	## A x i x v -> Ti x TA x e
	## Q x Tk x Ti x V
	## TV x i x k x TQ -> Ti x V x e x Q
	## i x Q x TK x V -> Ti x e x TV x K
	var _fast_result0:Matrix = _result[0].transpose()
	var learn_value:Matrix = _fast_result0._mul_t_fast(_result[4], 2)._mul_fast(errors[2], 2)
	learn_value.mul_self_by_number(rate)
	Value.min_self(learn_value)
#		print("Value learn ", learn_value)
	
	
	var learn_key:Matrix = _fast_result0._mul_fast(_result[3], 2)._mul_t_fast(errors[1], 2)._mul_fast(_result[1], 2)
#		print("Key learn ", learn_value)
	learn_key.mul_self_by_number(rate)
	Key.min_self(learn_key)
	
	var learn_query:Matrix = _fast_result0._mul_fast(errors[0], 2)._mul_t_fast(_result[3], 2)._mul_fast(_result[2], 2)
	learn_query.mul_self_by_number(rate)
	Query.min_self(learn_query)
#		print("Query learn ", learn_value)
	
	
#		next_learn = error.mul_t(Value).mul(Key).mul_t(Query)
	var next_learn_value = _result[4].transpose().mul(errors[2]).mul_t(Value)
	var next_learn_key = _result[3].mul_t(errors[1]).mul(_result[1]).mul_t(Key)
	var next_learn_query = errors[0].mul_t(_result[3]).mul(_result[2]).mul_t(Query)
#		print(_result[3].mul_t(error).mul(_result[1]).mul_t(Key))
#		print("error ", error)
#		print("Value ", Value)
#		print("next learn ", next_learn)
#		print(next_learn, "\n")
	return [next_learn_query, next_learn_key, next_learn_value]


func __next_learnxxx(error:Matrix):
	var next_learn:Matrix
	next_learn = error.mul_t(Value)
	#next_learn = error.mul(Key)#.mul(Value)
	#next_learn = error.mul_t(Query)#.mul_t(Value)
	
	next_learn.add_self(error.mul(Key))
	next_learn.add_self(error.mul_t(Query))
	next_learn.div_self_by_number(3.0)
	
#		print(next_learn.row_size, " ", next_learn.col_size)
	return next_learn

func to_dict()->Dictionary:
	return {
		"vector_size": Vector_size,
		"query": Query.to_dict(),
		"key": Key.to_dict(),
		"value": Value.to_dict(),
	}
