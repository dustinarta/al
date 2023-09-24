extends RefCounted
class_name Transformer2

var Layer:Array

func _init():
	pass

func init(vector_size:int, layer_size:int = 1):
	Layer.resize(layer_size)
	for i in range(layer_size):
		Layer[i] = Coder.new().init(vector_size)
	return self

func forward(input:Matrix):
	var result = input
	
	for coder in Layer:
		result = coder.forward(result)
#		print(result)
	
	return result



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
	
	func forward(input:Matrix):
		if input.col_size != Vector_size:
			printerr("Invalid vector size!")
			return null
		
		var query = input.mul(Query)
		var key = input.mul(Key)
		var value = input.mul(Value)
#		print(query.mul_t(key))
		return query.mul_t(key).softmax().div_self_by_number(sqrt(Vector_size)).mul(value).batch_normalization()
	
	func forward2(input1:Matrix, input2:Matrix):
		if input1.col_size != Vector_size and input2.col_size != Vector_size:
			printerr("Invalid vector size!")
			return null
		
		var query = input1.mul(Query)
		var key = input2.mul(Key)
		var value = input2.mul(Value)
		
		return query.mul_t(key).softmax().div_self_by_number(sqrt(Vector_size)).mul(value).batch_normalization()
	
	func to_dict()->Dictionary:
		return {
			"vector_size": Vector_size,
			"query": Query.to_dict(),
			"key": Key.to_dict(),
			"value": Value.to_dict(),
		}
	
