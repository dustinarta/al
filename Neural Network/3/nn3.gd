extends RefCounted
class_name NN3

enum ACTIVATION {
	SIGMOID,
	TANH,
	MAX,
	MIN,
	NONE
}

const Layer:Dictionary = {
	"a" : ACTIVATION.SIGMOID,
	"b" : [],
	"w" : [],
	"i" : 0,
	"o": 0
}
const e = 2.7181828459

var input:int
var layers:Array[Dictionary]
var is_biased:bool
var forward_result:Array

func _init(composition:PackedInt64Array, activations:PackedInt64Array = [], no_bias:bool = false):
	var size = composition.size()
	layers.resize(size-1)
	self.input = composition[0]
	var lastcount:int = self.input
	if no_bias:
		is_biased = false
	else:
		is_biased = true
	if activations.size() == 0:
		for i in range(1, size):
			var weights:PackedFloat64Array
			weights.resize(composition[i] * lastcount)
			var biases:PackedFloat64Array
			biases.resize(composition[i])
			layers[i-1] = Layer.duplicate()
			layers[i-1]["w"] = weights
			layers[i-1]["b"] = biases
			layers[i-1]["a"] = ACTIVATION.SIGMOID
			layers[i-1]["i"] = lastcount
			layers[i-1]["o"] = composition[i]
			lastcount = composition[i]
	else:
		if activations.size() != size:
			printerr("expected equal size!")
			return
		
		for i in range(1, size):
			var weights:PackedFloat64Array
			weights.resize(composition[i] * lastcount)
			var biases:PackedFloat64Array
			biases.resize(composition[i])
			layers[i-1] = Layer.duplicate()
			layers[i-1]["w"] = weights
			layers[i-1]["b"] = biases
			layers[i-1]["a"] = activations[i]
			layers[i-1]["i"] = lastcount
			layers[i-1]["o"] = composition[i]
			lastcount = composition[i]
	
	init_weight_and_bias()

func init_weight_and_bias():
	if is_biased:
		for layer in layers:
			var size = layer["w"].size()
			for i in range(size):
				layer["w"][i] = randf_range(-0.5, 0.5)
			for i in range(layer["o"]):
				layer["b"][i] = randf_range(-0.5, 0.5)
	else:
		for layer in layers:
			var size = layer["w"].size()
			for i in range(size):
				layer["w"][i] = randf_range(-0.5, 0.5)

func forward(inputs:PackedFloat64Array):
	if input != inputs.size():
		printerr("expected ", input, " input but given ", inputs.size())
		return null
	forward_result = []
	var result:PackedFloat64Array
	
	if is_biased:
		for layer in layers:
			var nextinput:PackedFloat64Array
			var w = layer["w"]
			var b = layer["b"]
			var a = layer["a"]
			var inputsize = layer["i"]
			var outputsize = layer["o"]
			result = []
			result.resize(outputsize)
			for i in range(outputsize):
				var res:float = 0
				for j in range(inputsize):
					var index = i * inputsize + j
					res += w[index]
				result[i] = activation(res + b[i], a)
			forward_result.append(result)
	else:
		for layer in layers:
			var nextinput:PackedFloat64Array
			var w = layer["w"]
			var b = layer["b"]
			var a = layer["a"]
			var inputsize = layer["i"]
			var outputsize = layer["o"]
			result = []
			result.resize(outputsize)
			for i in range(outputsize):
				var res:float = 0
				for j in range(inputsize):
					var index = i * inputsize + j
					res += w[index]
				result[i] = activation(res, a)
			forward_result.append(result)
	return forward_result

func backward(inputs:PackedFloat64Array, expected:PackedFloat64Array, count:int = 1000, rate:float = 0.01):
	if layers.front()["i"] != inputs.size():
		printerr("expected ", layers.front()["i"], " input but given ", inputs.size())
		return null
	if layers.back()["o"] != expected.size():
		printerr("expected ", layers.back()["o"], " input but given ", expected.size())
		return null
	if is_biased:
		_backward_bias(inputs, expected, count, rate)
	else:
		_backward_nobias(inputs, expected, count, rate)

func _backward_bias(inputs:PackedFloat64Array, expected:PackedFloat64Array, count:int = 1000, rate:float = 0.01):
	var inputsize = layers.back()["i"]
	var outputsize = layers.back()["o"]
	var w = layers.back()["w"]
	var b = layers.back()["b"]
	var a = layers.back()["a"]
	
	
	var error:PackedFloat64Array = []
	var futureerror:PackedFloat64Array = []
	var simplecode:PackedFloat64Array = []
	var thisinput:PackedFloat64Array = []
	var derivatives:PackedFloat64Array = []
	for repeat in range(count):
			###################################################
			#output layer
			forward_result = forward(inputs)
			inputsize = layers[-1]["i"]
			outputsize = layers[-1]["o"]
			w = layers[-1]["w"]
			b = layers[-1]["b"]
			a = layers[-1]["a"]
			error = []
			error.resize(outputsize)
			futureerror = []
			futureerror.resize(inputsize)
			simplecode.resize(outputsize)
			thisinput = forward_result[-2]
			derivatives = derivative_activations(forward_result[-1], a)
			for o in range(expected.size()):
				error[o] = (forward_result[-1][o] - expected[o])
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					futureerror[i] += simplecode[o] * w[o * inputsize + i]
					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
					b[o] -= simplecode[o]
	#		print(error)
			#####################################################
			#hidden layer
			for layer in range(layers.size()-2, 0, -1):
	#			print(layer)
				inputsize = layers[layer]["i"]
				outputsize = layers[layer]["o"]
				w = layers[layer]["w"]
				b = layers[layer]["b"]
				a = layers[layer]["a"]
				error = futureerror
				futureerror = []
				futureerror.resize(inputsize)
				simplecode.resize(outputsize)
				thisinput = forward_result[layer-1]
				derivatives = derivative_activations(forward_result[layer], a)
				for o in range(outputsize):
					simplecode[o] = error[o] * derivatives[o]
				
				for i in range(inputsize):
					for o in range(outputsize):
						futureerror[i] += simplecode[o] * w[o * inputsize + i]
						w[o * inputsize + i] -= simplecode[o] * thisinput[i]
						b[o] -= simplecode[o]
	#		print(error)
			####################################################
			#input layer
			inputsize = layers[0]["i"]
			outputsize = layers[0]["o"]
			w = layers[0]["w"]
			b = layers[0]["b"]
			error = futureerror
			futureerror = []
			futureerror.resize(inputsize)
			simplecode.resize(outputsize)
			thisinput = inputs
			derivatives = derivative_activations(forward_result[0], a)
			for o in range(outputsize):
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
					b[o] -= simplecode[o]

func _backward_nobias(inputs:PackedFloat64Array, expected:PackedFloat64Array, count:int = 1000, rate:float = 0.01):
	var inputsize = layers.back()["i"]
	var outputsize = layers.back()["o"]
	var w = layers.back()["w"]
	var a = layers.back()["a"]
	
	var error:PackedFloat64Array = []
	var futureerror:PackedFloat64Array = []
	var simplecode:PackedFloat64Array = []
	var thisinput:PackedFloat64Array = []
	var derivatives:PackedFloat64Array = []
	for repeat in range(count):
			###################################################
			#output layer
			forward_result = forward(inputs)
			inputsize = layers[-1]["i"]
			outputsize = layers[-1]["o"]
			w = layers[-1]["w"]
			a = layers[-1]["a"]
			error = []
			error.resize(outputsize)
			futureerror = []
			futureerror.resize(inputsize)
			simplecode.resize(outputsize)
			thisinput = forward_result[-2]
			derivatives = derivative_activations(forward_result[-1], a)
			for o in range(expected.size()):
				error[o] = (forward_result[-1][o] - expected[o])
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					futureerror[i] += simplecode[o] * w[o * inputsize + i]
					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
	#		print(error)
			#####################################################
			#hidden layer
			for layer in range(layers.size()-2, 0, -1):
	#			print(layer)
				inputsize = layers[layer]["i"]
				outputsize = layers[layer]["o"]
				w = layers[layer]["w"]
				a = layers[layer]["a"]
				error = futureerror
				futureerror = []
				futureerror.resize(inputsize)
				simplecode.resize(outputsize)
				thisinput = forward_result[layer-1]
				derivatives = derivative_activations(forward_result[layer], a)
				for o in range(outputsize):
					simplecode[o] = error[o] * derivatives[o]
				
				for i in range(inputsize):
					for o in range(outputsize):
						futureerror[i] += simplecode[o] * w[o * inputsize + i]
						w[o * inputsize + i] -= simplecode[o] * thisinput[i]
	#		print(error)
			####################################################
			#input layer
			inputsize = layers[0]["i"]
			outputsize = layers[0]["o"]
			w = layers[0]["w"]
			error = futureerror
			futureerror = []
			futureerror.resize(inputsize)
			simplecode.resize(outputsize)
			thisinput = inputs
			derivatives = derivative_activations(forward_result[0], a)
			for o in range(outputsize):
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					w[o * inputsize + i] -= simplecode[o] * thisinput[i]

func _train_with_error(inputs:PackedFloat64Array, errors:PackedFloat64Array):
	var inputsize = layers.back()["i"]
	var outputsize = layers.back()["o"]
	var w = layers.back()["w"]
	var b = layers.back()["b"]
	var a = layers.back()["a"]
	
	var error:PackedFloat64Array = []
	var futureerror:PackedFloat64Array = []
	var simplecode:PackedFloat64Array = []
	var thisinput:PackedFloat64Array = []
	var derivatives:PackedFloat64Array = []
	
	if is_biased:
		inputsize = layers[-1]["i"]
		outputsize = layers[-1]["o"]
		w = layers[-1]["w"]
		b = layers[-1]["b"]
		a = layers[-1]["a"]
		error = errors
		futureerror = []
		futureerror.resize(inputsize)
		simplecode.resize(outputsize)
		thisinput = forward_result[-2]
		derivatives = derivative_activations(forward_result[-1], a)
		for o in range(outputsize):
			simplecode[o] = error[o] * derivatives[o]
		
		for i in range(inputsize):
			for o in range(outputsize):
				futureerror[i] += simplecode[o] * w[o * inputsize + i]
				w[o * inputsize + i] -= simplecode[o] * thisinput[i]
				b[o] -= simplecode[o]
#		print(error)
		#####################################################
		#hidden layer
		for layer in range(layers.size()-2, 0, -1):
#			print(layer)
			inputsize = layers[layer]["i"]
			outputsize = layers[layer]["o"]
			w = layers[layer]["w"]
			b = layers[layer]["b"]
			a = layers[layer]["a"]
			error = futureerror
			futureerror = []
			futureerror.resize(inputsize)
			simplecode.resize(outputsize)
			thisinput = forward_result[layer-1]
			derivatives = derivative_activations(forward_result[layer], a)
			for o in range(outputsize):
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					futureerror[i] += simplecode[o] * w[o * inputsize + i]
					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
					b[o] -= simplecode[o]
#		print(error)
		####################################################
		#input layer
		inputsize = layers[0]["i"]
		outputsize = layers[0]["o"]
		w = layers[0]["w"]
		b = layers[0]["b"]
		error = futureerror
		futureerror = []
		futureerror.resize(inputsize)
		simplecode.resize(outputsize)
		thisinput = inputs
		derivatives = derivative_activations(forward_result[0], a)
		for o in range(outputsize):
			simplecode[o] = error[o] * derivatives[o]
		
		for i in range(inputsize):
			for o in range(outputsize):
				futureerror[i] += simplecode[o] * w[o * inputsize + i]
				w[o * inputsize + i] -= simplecode[o] * thisinput[i]
				b[o] -= simplecode[o]
	else:
		forward_result = forward(inputs)
		inputsize = layers[-1]["i"]
		outputsize = layers[-1]["o"]
		w = layers[-1]["w"]
		a = layers[-1]["a"]
		error = errors
		futureerror = []
		futureerror.resize(inputsize)
		simplecode.resize(outputsize)
		thisinput = forward_result[-2]
		derivatives = derivative_activations(forward_result[-1], a)
		for o in range(outputsize):
			simplecode[o] = error[o] * derivatives[o]
		
		for i in range(inputsize):
			for o in range(outputsize):
				futureerror[i] += simplecode[o] * w[o * inputsize + i]
				w[o * inputsize + i] -= simplecode[o] * thisinput[i]
#		print(error)
		#####################################################
		#hidden layer
		for layer in range(layers.size()-2, 0, -1):
#			print(layer)
			inputsize = layers[layer]["i"]
			outputsize = layers[layer]["o"]
			w = layers[layer]["w"]
			a = layers[layer]["a"]
			error = futureerror
			futureerror = []
			futureerror.resize(inputsize)
			simplecode.resize(outputsize)
			thisinput = forward_result[layer-1]
			derivatives = derivative_activations(forward_result[layer], a)
			for o in range(outputsize):
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					futureerror[i] += simplecode[o] * w[o * inputsize + i]
					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
#		print(error)
		####################################################
		#input layer
		inputsize = layers[0]["i"]
		outputsize = layers[0]["o"]
		w = layers[0]["w"]
		error = futureerror
		futureerror = []
		futureerror.resize(inputsize)
		simplecode.resize(outputsize)
		thisinput = inputs
		derivatives = derivative_activations(forward_result[0], a)
		for o in range(outputsize):
			simplecode[o] = error[o] * derivatives[o]
		
		for i in range(inputsize):
			for o in range(outputsize):
				futureerror[i] += simplecode[o] * w[o * inputsize + i]
				w[o * inputsize + i] -= simplecode[o] * thisinput[i]
	return futureerror

func activation(number:float, type:ACTIVATION):
	match type:
		ACTIVATION.TANH:
			return tanh(number)
		ACTIVATION.SIGMOID:
			return (1 / (1 + pow(e, -number)))
		ACTIVATION.NONE:
			return number
#
#func derivative_activation(number:float, type:ACTIVATION):
#	return (1 - pow(number, 2))

func derivative_activations(numbers:PackedFloat64Array, type:ACTIVATION):
	var result:PackedFloat64Array
	result.resize(numbers.size())
	match type:
		ACTIVATION.TANH:
			for n in range(numbers.size()):
				result[n] = (1 - pow(numbers[n], 2))
		ACTIVATION.SIGMOID:
			for n in range(numbers.size()):
				result[n] = (1 - numbers[n]) * numbers[n]
		ACTIVATION.NONE:
			result.fill(1.0)
	return result

func save():
	pass

func load():
	pass
