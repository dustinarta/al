extends RefCounted
class_name Coder2

var Query:Matrix
var Key:Matrix
var Value:Matrix

var Sequence_length:int
var Vector_size:int
var Head_size:int

var _result:Array

func init(vector_size:int, head_size:int):
	Vector_size = vector_size
	if (vector_size % head_size) != 0:
		printerr("unmatched for head size!")
		return null
	Head_size = head_size
	var num_range:float = 1.0/Vector_size
	Query = Matrix.new().init(vector_size, vector_size).self_randomize(-num_range, num_range)
	Key = Matrix.new().init(vector_size, vector_size).self_randomize(-num_range, num_range)
	Value = Matrix.new().init(vector_size, vector_size).self_randomize(-num_range, num_range)
	return self

static func init_from_dict(data:Dictionary)->Coder2:
	var coder:Coder2 = Coder2.new()
	coder.Vector_size = data["vector_size"]
	coder.Head_size = data["head_size"]
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
	var query = input._mul_fast(Query, 4)
	var key = input._mul_fast(Key, 4)
	var value = input._mul_fast(Value, 4)
	_result[0] = input#.duplicate()
	_result[1] = query#.duplicate()
	_result[2] = key#.duplicate()
	_result[3] = value#.duplicate()
	var attention = query._mul_t_fast(key, 4).div_self_by_number(sqrt(Vector_size)).softmax()
	_result[4] = attention#.duplicate()
	var output = attention._mul_fast(value, 4).batch_normalization()
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
	var queries = query.split_col(Head_size)
	var keys = key.split_col(Head_size)
	var values = value.split_col(Head_size)
	_result[0] = input#.duplicate()
	_result[1] = queries#.duplicate()
	_result[2] = keys#.duplicate()
	_result[3] = values#.duplicate()
	var attention = query.mul_t(key).div_self_by_number(sqrt(Vector_size)).softmax()
	var attentions = Matrix.multi_softmax(
		Matrix.multi_div_by_number(
			Matrix.multi_mul_t(queries, keys), sqrt(Vector_size)
		)
	)
	_result[4] = attentions#.duplicate()
	var output = Matrix.join_col(
		Matrix.multi_mul(
			attentions, values
		)
	).batch_normalization()
	
#	var output = attention.mul(value).batch_normalization()
	_result[5] = output.add_self(input)#.duplicate()
#	print("Queries result", _result[1], "\n")
#	print("Keys result", _result[2], "\n")
#	print("Values result", _result[3], "\n")
#	print("Attentions result", _result[4], "\n")
#	print("Output result", _result[5], "\n")
	return output

func forward2(input1:Matrix, input2:Matrix):
	if input1.col_size != Vector_size and input2.col_size != Vector_size:
		printerr("Invalid vector size!")
		return null
	
	var query = input1.mul(Query)
	var key = input2.mul(Key)
	var value = input2.mul(Value)
	
	return query.mul_t(key).div_self_by_number(sqrt(Vector_size)).softmax().mul(value).batch_normalization()

func learn(error:Matrix, rate:float = 0.0001):
	## A x i x v -> Ti x TA x e
	## Q x Tk x Ti x V
	## TV x i x k x TQ -> Ti x V x e x Q
	## i x Q x TK x V -> Ti x e x TV x K
	var _fast_result0:Matrix = _result[0].transpose()
	var learn_value:Matrix = _fast_result0._mul_t_fast(_result[4], 4)._mul_fast(error, 4)
	learn_value.mul_self_by_number(rate)
	Value.min_self(learn_value)
#		print("Value learn ", learn_value)
	
	
	var learn_key:Matrix = _fast_result0._mul_fast(_result[3], 4)._mul_t_fast(error, 4)._mul_fast(_result[1], 4)
#		print("Key learn ", learn_value)
	learn_key.mul_self_by_number(rate)
	Key.min_self(learn_key)
	
	var learn_query:Matrix = _fast_result0._mul_fast(error, 4)._mul_t_fast(_result[3], 4)._mul_fast(_result[2], 4)
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
	var learn_value:Matrix = _fast_result0._mul_t_fast(_result[4], 4)._mul_fast(errors[2], 4)
	learn_value.mul_self_by_number(rate)
	Value.min_self(learn_value)
#		print("Value learn ", learn_value)
	
	
	var learn_key:Matrix = _fast_result0._mul_fast(_result[3], 4)._mul_t_fast(errors[1], 4)._mul_fast(_result[1], 4)
#		print("Key learn ", learn_value)
	learn_key.mul_self_by_number(rate)
	Key.min_self(learn_key)
	
	var learn_query:Matrix = _fast_result0._mul_fast(errors[0], 4)._mul_t_fast(_result[3], 4)._mul_fast(_result[2], 4)
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

func __learn(error:Matrix, rate:float = 0.0001):
	var errors:Array[Matrix] = error.split_col(Head_size)
	var inputs:Array[Matrix] = _result[0].split_col(Head_size)
	
	var next_learn:Matrix = Matrix.new().init(Vector_size, 0)
	var Queries = Query.split_col(Head_size)
	var Keys = Key.split_col(Head_size)
	var Values = Value.split_col(Head_size)
	
	for h in range(Head_size):
		var this_next_learn:Matrix = _result[4][h].transpose().mul(errors[h]).mul_t(Values[h])
		this_next_learn.add_self(_result[3][h].mul_t(errors[h]).mul(_result[1][h]).mul_t(Keys[h]))
		this_next_learn.add_self(errors[h].mul_t(_result[3][h]).mul(_result[2][h]).mul_t(Queries[h]))
		this_next_learn.mul_self_by_number(0.333333)
		next_learn.concat_col(this_next_learn)
	
	var learn_query:Matrix = Matrix.new().init(Vector_size, 0)
	var learn_key:Matrix = Matrix.new().init(Vector_size, 0)
	var learn_value:Matrix = Matrix.new().init(Vector_size, 0)
	
	for h in range(Head_size):
		var _fast_result0:Matrix = inputs[h].transpose()
		
		var temp_learn_value:Matrix = _fast_result0._mul_t_fast(_result[4][h], 4)._mul_fast(errors[h], 4)
		learn_value.concat_col(temp_learn_value)
		
		var temp_learn_key:Matrix = _fast_result0._mul_fast(_result[3][h], 4)._mul_t_fast(errors[h], 4)._mul_fast(_result[1][h], 4)
		learn_key.concat_col(temp_learn_key)
		
		var temp_learn_query:Matrix = _fast_result0._mul_fast(errors[h], 4)._mul_t_fast(_result[3][h], 4)._mul_fast(_result[2][h], 4)
		learn_query.concat_col(temp_learn_query)
		
	learn_query.mul_self_by_number(rate)
	learn_key.mul_self_by_number(rate)
	learn_value.mul_self_by_number(rate)
	Query.min_self(learn_query)
	Key.min_self(learn_key)
	Value.min_self(learn_value)
	
	return next_learn

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
		"head_size": Head_size,
		"query": Query.to_dict(),
		"key": Key.to_dict(),
		"value": Value.to_dict(),
	}

