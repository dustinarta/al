extends RefCounted
class_name Coder3

var Query:Matrix
var Key:Matrix
var Value:Matrix
var Batch:Dictionary

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
	Batch = {
		"w":1.0, "b":0.0
	}
	var num_range:float = 1.0/pow(vector_size*3, 2.0)
#	var num_range:float = sqrt(1.0/(vector_size*6))
#	var num_range:float = 1.0/vector_size
	Query = Matrix.new().init(vector_size, vector_size).self_randomize(-num_range, num_range)
	Key = Matrix.new().init(vector_size, vector_size).self_randomize(-num_range, num_range)
	Value = Matrix.new().init(vector_size, vector_size).self_randomize(-num_range, num_range)
#	Query = Matrix.new().init(vector_size, vector_size, num_range)
#	Key = Matrix.new().init(vector_size, vector_size, num_range)
#	Value = Matrix.new().init(vector_size, vector_size, num_range)
#	Query = Matrix.new().init(vector_size, vector_size).init_box_muller(num_range, num_range)
#	Key = Matrix.new().init(vector_size, vector_size).init_box_muller(num_range, num_range)
#	Value = Matrix.new().init(vector_size, vector_size).init_box_muller(num_range, num_range)
#	Query = Matrix.new().init(vector_size, vector_size).init_box_muller(0, num_range)
#	Key = Matrix.new().init(vector_size, vector_size).init_box_muller(0, num_range)
#	Value = Matrix.new().init(vector_size, vector_size).init_box_muller(0, num_range)
	return self

static func init_from_dict(data:Dictionary)->Coder3:
	var coder:Coder3 = Coder3.new()
	coder.Vector_size = data["vector_size"]
	coder.Head_size = data["head_size"]
	coder.Query = Matrix.new().load_from_dict(data["query"])
	coder.Key = Matrix.new().load_from_dict(data["key"])
	coder.Value = Matrix.new().load_from_dict(data["value"])
	coder.Batch = data["batch"]
	return coder
#
#func forward_fast(input:Matrix):
#	if input.col_size != Vector_size:
#		printerr("Invalid vector size!")
#		return null
#	_result.clear()
#	_result.resize(7)
#	var query = input._mul_fast(Query, 4)
#	var key = input._mul_fast(Key, 4)
#	var value = input._mul_fast(Value, 4)
#	_result[0] = input#.duplicate()
#	_result[1] = input#.duplicate()
#	_result[2] = query#.duplicate()
#	_result[3] = key#.duplicate()
#	_result[4] = value#.duplicate()
#	var attention = query._mul_t_fast(key, 4).div_self_by_number(sqrt(Vector_size)).softmax()
#	_result[5] = attention#.duplicate()
#	var output = attention._mul_fast(value, 4).activation_normalization()
#	_result[6] = output.add_self(input)#.duplicate()
##		print("Query result", _result[1], "\n")
##		print("Key result", _result[2], "\n")
##		print("Value result", _result[3], "\n")
##		print("Attention result", _result[4], "\n")
##		print("Output result", _result[5], "\n")
#	return output

func forward(input:Matrix):
	if input.col_size != Vector_size:
		printerr("Invalid vector size!")
		return null
	_result.clear()
	_result.resize(8)
	var query = input.mul(Query)
	var key = input.mul(Key)
	var value = input.mul(Value)
	var queries = query.split_col(Head_size)
	var keys = key.split_col(Head_size)
	var values = value.split_col(Head_size)
	_result[0] = input#.duplicate()
	_result[1] = input#.duplicate()
	_result[2] = queries#query#.duplicate()
	_result[3] = keys#key#.duplicate()
	_result[4] = values#value#.duplicate()
#	var attention = query.mul_t(key).div_self_by_number(sqrt(Vector_size)).softmax()
	var _temp1 = Matrix.multi_mul_t(queries, keys)
#	print("Queries x Keys ", _temp1)
	var attentions = Matrix.multi_softmax(
		Matrix.multi_div_by_number(
			_temp1, Vector_size#1.0
		)
	)
	_result[5] = attentions#attention#.duplicate()
	var output = Matrix.join_col(
		Matrix.multi_mul(
			attentions, values
		)
	)#
	
#	var output = attention.mul(value).batch_normalization()
	_result[6] = output.add_self(input).activation_normalization()
	_result[7] = _result[6].batch_normalization(Batch["w"], Batch["b"])#.duplicate()
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
	
	return query.mul_t(key).div_self_by_number(sqrt(Vector_size)).softmax().mul(value).activation_normalization()

func learn(error:Matrix, rate:float = 0.1/pow(Vector_size, 4.0)):
#	print("error ", error.row_size)
	var learn_batch_w:float = error.mul2(_result[6]).add_on_all() * rate
	var learn_batch_b:float = error.add_on_all() * rate
	var sequence_length:int = error.row_size
	error.mul_self_by_number(Batch["w"])
	var errors:Array[Matrix] = error.split_col(Head_size)
	var input1:Matrix = _result[0].transpose()
	var input2:Matrix = _result[1].transpose()
	
	Batch["w"] -= learn_batch_w / error.get_total_element()
	Batch["b"] -= learn_batch_b / error.get_total_element()
	var next_learn:Matrix = Matrix.new().init(sequence_length, Vector_size)
	var Queries = Query.split_col(Head_size)
	var Keys = Key.split_col(Head_size)
	var Values = Value.split_col(Head_size)
	
	
#	print("now next learn ", next_learn.row_size, " ", next_learn.col_size)
#	var learn_query:Matrix = Matrix.new().init(Vector_size, 0)
#	var learn_key:Matrix = Matrix.new().init(Vector_size, 0)
#	var learn_value:Matrix = Matrix.new().init(Vector_size, 0)
	var learn_query:Matrix
	var learn_key:Matrix
	var learn_value:Matrix
	var this_learn_array_query:Array[Matrix]
	var this_learn_array_key:Array[Matrix]
	var this_learn_array_value:Array[Matrix]
	this_learn_array_query.resize(Head_size)
	this_learn_array_key.resize(Head_size)
	this_learn_array_value.resize(Head_size)
	var this_learn_query:Matrix = Matrix.new().init(sequence_length, 0)
	var this_learn_key:Matrix = Matrix.new().init(sequence_length, 0)
	var this_learn_value:Matrix = Matrix.new().init(sequence_length, 0)
#	var this_learn_query:Matrix = Matrix.new().init(0, sequence_length)
#	var this_learn_key:Matrix = Matrix.new().init(0, sequence_length)
#	var this_learn_value:Matrix = Matrix.new().init(0, sequence_length)
	
	for h in range(Head_size):
		var temp_learn_value:Matrix = _result[5][h]._mul_fast(errors[h], 4)
		var temp_learn_key:Matrix = _result[4][h]._mul_t_fast(errors[h], 4)._mul_fast(_result[2][h], 4)
		var temp_learn_query:Matrix = errors[h]._mul_t_fast(_result[4][h], 4)._mul_fast(_result[3][h], 4)
		
#		print("temp learn value ", temp_learn_value.row_size, " ", temp_learn_value.col_size)
#		false
#		this_learn_value.self_concat_row(temp_learn_value)
#		this_learn_key.self_concat_row(temp_learn_key)
#		this_learn_query.self_concat_row(temp_learn_query)

#		this_learn_value.self_concat_col(temp_learn_value)
#		this_learn_key.self_concat_col(temp_learn_key)
#		this_learn_query.self_concat_col(temp_learn_query)
		
		this_learn_array_value[h] = temp_learn_value
		this_learn_array_key[h] = temp_learn_key
		this_learn_array_query[h] = temp_learn_query
		
#	print("this learn value ", this_learn_value.row_size, " ", this_learn_value.col_size)
	
#	Matrix.multi_reverse_row(this_learn_array_query)
#	Matrix.multi_reverse_row(this_learn_array_key)
#	Matrix.multi_reverse_row(this_learn_array_value)
	
#	this_learn_array_query.reverse()
#	this_learn_array_key.reverse()
#	this_learn_array_value.reverse()
	
	this_learn_query = Matrix.join_col(this_learn_array_query)
	this_learn_key = Matrix.join_col(this_learn_array_key)
	this_learn_value = Matrix.join_col(this_learn_array_value)
	
#	this_learn_query.self_reverse_row()
#	this_learn_key.self_reverse_row()
#	this_learn_value.self_reverse_row()
	
	
	learn_value = input2._mul_fast(this_learn_value, 4)
	learn_key = input2._mul_fast(this_learn_key, 4)
	learn_query = input1._mul_fast(this_learn_query, 4)
	
	learn_query.mul_self_by_number(rate)
	learn_key.mul_self_by_number(rate)
	learn_value.mul_self_by_number(rate)
	
#	print(learn_query)
	
	Query.min_self(learn_query)
	Key.min_self(learn_key)
	Value.min_self(learn_value)
	
	for h in range(Head_size):
		var this_next_learn:Matrix = _result[5][h].transpose().mul(errors[h]).mul_t(Values[h])
		this_next_learn.add_self(_result[4][h].mul_t(errors[h]).mul(_result[2][h]).mul_t(Keys[h]))
		this_next_learn.add_self(errors[h].mul_t(_result[4][h]).mul(_result[3][h]).mul_t(Queries[h]))
#		this_next_learn.mul_self_by_number(0.333333)
#		print("this next learn ", this_next_learn.row_size, " ", this_next_learn.col_size)
		next_learn.add_self(this_next_learn)
	next_learn.div_self_by_number(Head_size)
	return next_learn

func to_dict()->Dictionary:
	var data:Dictionary = {
		"vector_size": Vector_size,
		"head_size": Head_size,
		"batch": Batch,
		"query": Query.to_dict(),
		"key": Key.to_dict(),
		"value": Value.to_dict()
	}
#	print(data)
	return data

