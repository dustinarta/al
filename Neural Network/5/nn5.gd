extends RefCounted
class_name NN5

var Input_count:int
var Layers:Array[Matrix]
var Layer_count:int
var Activations:PackedInt64Array

enum ActivationType{
	None,
	Sigmoid,
	Tanh
}

var results:Array

func _init():
	pass

func init(input_count:int, layers:PackedInt64Array, activations:PackedInt64Array = []):
	Input_count = input_count
	
	var thisinput = input_count
	var layer_size = layers.size()
	Layers.resize(layer_size)
	Layer_count = layer_size
	Activations.resize(layer_size)
	if activations.is_empty():
		for l in range(layer_size):
			var layer = Matrix.new().init(thisinput, layers[l]).self_randomize(-2.0, 2.0)
			Layers[l] = layer
			thisinput = layers[l]
			Activations[l] = ActivationType.None
	else:
		for l in range(layer_size):
			var layer = Matrix.new().init(thisinput, layers[l]).self_randomize(-2.0, 2.0)
			Layers[l] = layer
			thisinput = layers[l]
			Activations[l] = activations[l]

func forward(input:PackedFloat64Array):
	if input.size() != Input_count:
		printerr("Invalid input count! expected ", Input_count)
		return null
	var result:Matrix = Matrix.new().fill_force([input])
	results.append(result)
	for i in range(Layer_count):
		result = activation( result.mul(Layers[i]), Activations[i])
		results.append(result)
	return result

func backward(input:PackedFloat64Array, expected:PackedFloat64Array):
	results.clear()
	var result = forward(input)
	var expected_matrix = Matrix.new().fill_force([expected])
	var error = result.min( expected_matrix ).mul2( derivative_activation(results[-1].duplicate(), Activations[-1]) )
	var learn:Matrix
	var new_layer:Array[Matrix]
	new_layer.resize(Layer_count)
	for l in range(Layer_count-1, 0, -1):
#		var learn = error.transpose().mul(outputs[l-1])
		learn = results[l].transpose().mul(error)
		new_layer[l] = learn.mul_self_by_number(0.1)
		error = error.mul_t(Layers[l]).mul2( derivative_activation(results[l].duplicate(), Activations[l-1]) )
#		print(learn)
	learn = results[0].transpose().mul(error)
	new_layer[0] = learn.mul_self_by_number(0.1)
	
	for l in range(Layer_count):
		Layers[l].min_self(new_layer[l])
	
#	print(learn)

func activation(result:Matrix, activation_type:int):
	var result_array = result.data[0]
	
	match activation_type:
		ActivationType.None:
			return result
		ActivationType.Tanh:
			for i in range(result_array.size()):
				result_array[i] = tanh(result_array[i])
			return result
		ActivationType.Sigmoid:
			for i in range(result_array.size()):
				result_array[i] = 1/(pow(2.71828, -result_array[i])) 
			return result
		_:
			printerr("undfined activation")
	return null

func derivative_activation(result:Matrix, activation_type:int):
	var result_array = result.data[0]
	
	match activation_type:
		ActivationType.None:
			result_array.fill(1.0)
			return result
		ActivationType.Tanh:
			for i in range(result_array.size()):
				result_array[i] = 1 - pow(result_array[i], 2)
			return result
		ActivationType.Sigmoid:
			for i in range(result_array.size()):
				result_array[i] *= (1 - result_array[i]) 
			return result
		_:
			printerr("undfined activation")
	return null
