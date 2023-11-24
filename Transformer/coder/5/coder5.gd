extends RefCounted
class_name Coder5

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
	var num_range:float = 1.0#/(Vector_size/Head_size)
#	var num_range:float = 0.1 + 1.0/(Vector_size/Head_size)
	Query = Matrix.new().init(vector_size, vector_size).self_randomize(-num_range, num_range)
	Key = Matrix.new().init(vector_size, vector_size).self_randomize(-num_range, num_range)
	Value = Matrix.new().init(vector_size, vector_size).self_randomize(-num_range, num_range)
#	Query = Matrix.new().init(vector_size, vector_size, 1.0)
#	Key = Matrix.new().init(vector_size, vector_size, 1.0)
#	Value = Matrix.new().init(vector_size, vector_size, 1.0)

func init_from_dict(data:Dictionary):
	Vector_size = data["Vector_size"]
	Head_size = data["Head_size"]
	Query = Matrix.init_from_dict(data["Query"])
	Key = Matrix.init_from_dict(data["Key"])
	Value = Matrix.init_from_dict(data["Value"])

func save(path:String):
	var data = to_dict()
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(
		JSON.stringify(data, "\t", false, true)
	)
	file.close()

func load(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(
		file.get_as_text()
	)
	init_from_dict(data)

func to_dict()->Dictionary:
	return {
		"Vector_size" : Vector_size,
		"Head_size" : Head_size,
		"Query" : Query.to_dict(),
		"Key" : Key.to_dict(),
		"Value" : Value.to_dict(),
	}

func forward(input1:Matrix, input2:Matrix)->Matrix:
	if input1.row_size != input2.row_size:
		printerr("invalid size of row!")
		return null
	
	if input1.col_size != Vector_size and input2.col_size != Vector_size:
		printerr("Invalid vector size!")
		return null
	_result.clear()
	_result.resize(8)
	var query = input1.mul(Query)
	var key = input2.mul(Key)
	var value = input2.mul(Value)
	var queries = query.split_col(Head_size)
	var keys = key.split_col(Head_size)
	var values = value.split_col(Head_size)
	
	_result[0] = input1
	_result[1] = input2
	_result[2] = queries
	_result[3] = keys
	_result[4] = values
	
	var attentions = Matrix.multi_mul_t(queries, keys)
	_result[5] = attentions
	var output = Matrix.join_col(
		Matrix.multi_mul(
			attentions, values
		)
	)
	_result[6] = output
	_result[7] = output.add(input1)
	
	return _result[7]

func learn(error:Matrix, rate:float = 0.0001/pow(Vector_size/Head_size, 4.0)):
#	print("error ", error.row_size)
#	var learn_batch_w:float = error.mul2(_result[6]).add_on_all() * rate
#	var learn_batch_b:float = error.add_on_all() * rate
	var sequence_length:int = error.row_size
#	error.mul_self_by_number(Batch["w"])
	var errors:Array[Matrix] = error.split_col(Head_size)
	var input1:Matrix = _result[0].transpose()
	var input2:Matrix = _result[1].transpose()
#	print(error.data[0])
#	Batch["w"] -= learn_batch_w / error.get_total_element()
#	Batch["b"] -= learn_batch_b / error.get_total_element()
	var next_learn:Matrix = Matrix.new().init(sequence_length, Vector_size)
	var Queries = Query.split_col(Head_size)
	var Keys = Key.split_col(Head_size)
	var Values = Value.split_col(Head_size)
	
	for h in range(Head_size):
		var this_next_learn:Matrix = _result[5][h].transpose().mul(errors[h]).mul_t(Values[h])
		this_next_learn.add_self(_result[4][h].mul_t(errors[h]).mul(_result[2][h]).mul_t(Keys[h]))
		this_next_learn.add_self(errors[h].mul_t(_result[4][h]).mul(_result[3][h]).mul_t(Queries[h]))
		this_next_learn.mul_self_by_number(0.333333)
#		print("this next learn ", this_next_learn.row_size, " ", this_next_learn.col_size)
		next_learn.add_self(this_next_learn)
	next_learn.div_self_by_number(Head_size)
	next_learn.mul_self_by_number(rate)
	
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
	
	for h in range(Head_size):
		var temp_learn_value:Matrix = _result[5][h]._mul_fast(errors[h], 4)
		var temp_learn_key:Matrix = _result[4][h]._mul_t_fast(errors[h], 4)._mul_fast(_result[2][h], 4)
		var temp_learn_query:Matrix = errors[h]._mul_t_fast(_result[4][h], 4)._mul_fast(_result[3][h], 4)
		this_learn_array_value[h] = temp_learn_value
		this_learn_array_key[h] = temp_learn_key
		this_learn_array_query[h] = temp_learn_query
		
	this_learn_query = Matrix.join_col(this_learn_array_query)
	this_learn_key = Matrix.join_col(this_learn_array_key)
	this_learn_value = Matrix.join_col(this_learn_array_value)
	
	learn_value = input2._mul_fast(this_learn_value, 4)
	learn_key = input2._mul_fast(this_learn_key, 4)
	learn_query = input1._mul_fast(this_learn_query, 4)
	
	learn_query.mul_self_by_number(rate)
	learn_key.mul_self_by_number(rate)
	learn_value.mul_self_by_number(rate)
	
	Query.min_self(learn_query)
	Key.min_self(learn_key)
	Value.min_self(learn_value)
#	Query.self_minmax_normalization_range(-1.0, 1.0)
#	Key.self_minmax_normalization_range(-1.0, 1.0)
#	Value.self_minmax_normalization_range(-1.0, 1.0)
	
	return next_learn
