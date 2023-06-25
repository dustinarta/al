extends RefCounted
class_name NN4Row

"""
Spesific model for Sentence Embedding
Rules:
	- no bias
	- only 1 layer
	- only modify input
"""

enum ACTIVATION {
	NONE = 0,
	SOFTMAX,
	SIGMOID,
	TANH,
	MAX,
	MIN
}

const E = 2.7181828459

var input_size:int
var output_size:int
var weights:PackedFloat64Array
#var biases:PackedFloat64Array
var activation:ACTIVATION

var _test_mode:bool = false
var path:String
var forward_result:Array

func _init():
	pass

func init(inputcount:int, outputcount:int, activationtype:ACTIVATION):
	input_size = inputcount
	output_size = outputcount
	
	weights.resize(inputcount*outputcount)
#	biases.resize(outputcount)
	activation = activationtype
	init_weight_and_bias()
	return self

func init_weight_and_bias():
	for w in range(weights.size()):
		weights[w] = randf_range(-1.0, 1.0)
		
#	for b in range(biases.size()):
#		biases[b] = randf_range(-1.0, 1.0)

func add_input(count:int = 1):
	var new_weight:PackedFloat64Array
	new_weight.resize(count * output_size)
	for w in range(count * output_size):
		new_weight[w] = randf_range(-1.0, 1.0)
	input_size += count
	weights.append_array(new_weight)

func forward(inputs:PackedFloat64Array):
	if inputs.size() != input_size:
		printerr("expected ", input_size, " but given ", inputs.size())
		return null
	
	var results:PackedFloat64Array
	results.resize(output_size)
	for o in range(output_size):
		var res:float = 0.0
		for i in range(input_size):
			res += inputs[i] * weights[i * output_size + o]
		results[o] = res
	results = activations(results, activation)
	forward_result = results
	return results

func forward_by_id(input:int):
	if input >= input_size:
		printerr("maximum id is ", input_size, " but given ", input)
		return null
	
	var results:PackedFloat64Array
	results.resize(output_size)
	for o in range(output_size):
		var res:float = 0.0
		res = weights[input * output_size + o]
		results[o] = res
	results = activations(results, activation)
	forward_result = results
	return results

func train(inputs:PackedFloat64Array, expected:PackedFloat64Array):
	var results
	var derivatives
	var errors:PackedFloat64Array
	var futureerrors:PackedFloat64Array
	
	errors.resize(output_size)
	futureerrors.resize(input_size)
	results = forward(inputs)
	for o in range(output_size):
		errors[o] = expected[o] - results[o]
	
	derivatives = derivative_activations(results, activation)
	for i in range(input_size):
		var error:float = 0.0
		for o in range(output_size):
			error += errors[o] * derivatives[o] * weights[i * output_size + o]
		futureerrors[i] = error
	
	for i in range(input_size):
		for o in range(output_size):
			weights[i * output_size + o] += errors[o] * derivatives[o] * inputs[i]
	
	return futureerrors

func train_with_error(inputs:PackedFloat64Array, errors:PackedFloat64Array):
	var results
	var derivatives
	var futureerrors:PackedFloat64Array
	
	futureerrors.resize(input_size)
	results = forward(inputs)
	
	derivatives = derivative_activations(results, activation)
	for i in range(input_size):
		var error:float = 0.0
		for o in range(output_size):
			error += errors[o] * derivatives[o] * weights[i * output_size + o]
		futureerrors[i] = error
	
	for i in range(input_size):
		for o in range(output_size):
			weights[i * output_size + o] += errors[o] * derivatives[o] * inputs[i]
	
	return futureerrors

func activations(numbers:PackedFloat64Array, type:ACTIVATION):
	var size:int = numbers.size()
	var result:PackedFloat64Array
	result.resize(numbers.size())
	match type:
		ACTIVATION.TANH:
			for i in range(size):
				result[i] = tanh(numbers[i])
		ACTIVATION.SIGMOID:
			for i in range(size):
				result[i] = (1 / (1 + pow(E, -numbers[i])))
		ACTIVATION.NONE:
			return numbers
		ACTIVATION.SOFTMAX:
			var total:float = 0.0
			for e in range(size):
				var res = pow(E, numbers[e])
				result[e] = res
				total += res
			for e in range(size):
				result[e] /= total
		_:
			printerr("UNCATCHED ", ACTIVATION.keys()[type])
	return result

func derivative_activations(numbers:PackedFloat64Array, type:ACTIVATION):
	var size:int = numbers.size()
	var result:PackedFloat64Array
	result.resize(numbers.size())
	match type:
		ACTIVATION.TANH:
			for n in range(size):
				result[n] = (1 - pow(numbers[n], 2))
		ACTIVATION.SIGMOID:
			for n in range(size):
				result[n] = (1 - numbers[n]) * numbers[n]
		ACTIVATION.NONE:
			result.fill(1.0)
		ACTIVATION.SOFTMAX:
			for n in range(size):
				result[n] = (1 - numbers[n]) * numbers[n]
		_:
			printerr("UNCATCHED ", ACTIVATION.keys()[type])
	return result

func _to_dictionary()->Dictionary:
	var data:Dictionary = {}
	data["input"] = input_size
	data["output"] = output_size
	data["weights"] = weights
#	data["biases"] = biases
	data["activation"] = activation
	return data

func save(path:String = self.path):
	FileAccess.open(path, FileAccess.WRITE).store_string(
		JSON.stringify(self._to_dictionary(), "\t")
	)

func load(path:String = self.path):
	var data:Dictionary = JSON.parse_string(
		FileAccess.open(path, FileAccess.READ).get_as_text()
	)
	self.path = path
	load_from_dict(data)

func load_from_dict(data:Dictionary):
	input_size = data["input"]
	output_size = data["output"]
	weights = data["weights"]
#	biases = data["biases"]
	activation = data["activation"]

