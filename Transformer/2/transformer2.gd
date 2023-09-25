extends RefCounted
class_name Transformer2

var Layer:Array[Coder]

func _init():
	pass

func init(vector_size:int, layer_size:int = 1):
	Layer.resize(layer_size)
	for i in range(layer_size):
		Layer[i] = Coder.new().init(vector_size)
	return self

func save(_path:String):
	var f = FileAccess.open(_path, FileAccess.WRITE)
	var layer:Array
	layer.resize(Layer.size())
	for i in range(Layer.size()):
		layer[i] = Layer[i].to_dict()
	f.store_string(
		JSON.stringify(
			{
				"layer" : layer
			},
			"\t", false, true
		)
	)
	f.close()

func load(_path:String):
	var f = FileAccess.open(_path, FileAccess.READ)
	var data = JSON.parse_string(
		f.get_as_text()
	)
	f.close()
	var layer:Array = data["layer"]
	Layer.resize(layer.size())
	
	for i in range(layer.size()):
		Layer[i] = Coder.init_from_dict(layer[i])
	return self

func forward(input:Matrix):
	var result = input
	
	for coder in Layer:
		result = coder.forward(result)
#		print(result)
	
	return result

func learn(error:Matrix):
	
	Layer[0].learn(error)
	

class Coder:
	var Query:Matrix
	var Key:Matrix
	var Value:Matrix
	
	var Sequence_length:int
	var Vector_size:int
	
	var _result:Array
	
	func init(vector_size:int):
		Vector_size = vector_size
		var num_range:float = 0.3
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
	
	func forward(input:Matrix):
		if input.col_size != Vector_size:
			printerr("Invalid vector size!")
			return null
		_result.clear()
		_result.resize(6)
		var query = input.mul(Query)
		var key = input.mul(Key)
		var value = input.mul(Value)
		_result[0] = input.duplicate()
		_result[1] = query.duplicate()
		_result[2] = key.duplicate()
		_result[3] = value.duplicate()
		var attention = query.mul_t(key).div_self_by_number(sqrt(Vector_size)).softmax()
		_result[4] = attention.duplicate()
		var output = attention.mul(value).batch_normalization()
		_result[5] = output.duplicate()
		return output
	
	func forward2(input1:Matrix, input2:Matrix):
		if input1.col_size != Vector_size and input2.col_size != Vector_size:
			printerr("Invalid vector size!")
			return null
		
		var query = input1.mul(Query)
		var key = input2.mul(Key)
		var value = input2.mul(Value)
		
		return query.mul_t(key).div_self_by_number(sqrt(Vector_size)).softmax().mul(value).batch_normalization()
	
	func learn(error:Matrix):
		## A x i x v -> Ti x TA x e
		## Q x Tk x Ti x V
		## TV x i x k x TQ -> Ti x V x e x Q
		## i x Q x TK x V -> Ti x e x TV x K
		var learn_value:Matrix = _result[0].transpose().mul_t(_result[4]).mul(error)
#		print(learn_value.row_size, " ", learn_value.col_size)
		learn_value.div_self_by_number(1000.0)
		Value.min_self(learn_value)
#		print(learn_value)
		
		var learn_key:Matrix = _result[0].transpose().mul(_result[3]).mul_t(error).mul(_result[1])
#		print(learn_key.row_size, " ", learn_key.col_size)
		learn_key.div_self_by_number(1000.0)
		Key.min_self(learn_key)
		
		var learn_query:Matrix = _result[0].transpose().mul(error)#.mul_t(_result[3]).mul(_result[2])
#		print(learn_query)
#		print(_result[0].transpose())
#		print(error)
		learn_query.div_self_by_number(1000.0)
		Query.min_self(learn_query)
		
	
	func to_dict()->Dictionary:
		return {
			"vector_size": Vector_size,
			"query": Query.to_dict(),
			"key": Key.to_dict(),
			"value": Value.to_dict(),
		}
	
