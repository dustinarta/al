extends RefCounted
class_name NN3

enum ACTIVATION {
	NONE = 0,
	SOFTMAX,
	SIGMOID,
	TANH,
	MAX,
	MIN
}

const Layer:Dictionary = {
	"a" : ACTIVATION.SIGMOID,
	"b" : [],
	"w" : [],
	"i" : 0,
	"o": 0
}
const E = 2.7181828459

var _test_mode:bool = false

var path:String
var input:int
var layers:Array
var is_biased:bool
var forward_result:Array

func _init():
	pass

func init(composition:PackedInt64Array, activations:PackedInt64Array = [], no_bias:bool = false):
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
		if activations.size() != size-1:
			printerr("expected equal activation size!")
			return
		
		for i in range(1, size):
			var weights:PackedFloat64Array
			weights.resize(composition[i] * lastcount)
			var biases:PackedFloat64Array
			biases.resize(composition[i])
			layers[i-1] = Layer.duplicate()
			layers[i-1]["w"] = weights
			layers[i-1]["b"] = biases
			layers[i-1]["a"] = activations[i-1]
			layers[i-1]["i"] = lastcount
			layers[i-1]["o"] = composition[i]
			lastcount = composition[i]
	
	init_weight_and_bias()

func init_weight_and_bias():
	if _test_mode:
		if is_biased:
			for layer in layers:
				layer["w"].fill(0.5)
				layer["b"].fill(0.5)
		else:
			for layer in layers:
				layer["w"].fill(0.5)
	else:
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
	var nextinput:PackedFloat64Array = inputs
	
	if is_biased:
		for layer in layers:
			var w = layer["w"]
			var b = layer["b"]
			var a = layer["a"]
			var inputsize = layer["i"]
			var outputsize = layer["o"]
			result = []
			result.resize(outputsize)
			if w.size() > 1000:
				var t1 = Thread.new()
				var t2 = Thread.new()
				t1.start(Callable(_multi_thread1).bindv([]))
				t1.start(Callable(_multi_thread1).bindv([]))
			else:
				for i in range(outputsize):
					var res:float = 0
					for j in range(inputsize):
						res += w[i * inputsize + j] * nextinput[j]
					result[i] = res + b[i]
			result = activations(result, a)
			nextinput = result
			forward_result.append(result)
	else:
		for layer in layers:
			var w = layer["w"]
			var a = layer["a"]
			var inputsize = layer["i"]
			var outputsize = layer["o"]
			result = []
			result.resize(outputsize)
			for i in range(outputsize):
				var res:float = 0
				for j in range(inputsize):
					var index = i * inputsize + j
					res += w[index] * nextinput[j]
				result[i] = res
			result = activations(result, a)
			nextinput = result
			forward_result.append(result)
	return forward_result.back()

func _multi_thread1(from, to, w, b, inputsize, outputsize, nextinput):
	var result:Array
	result.resize(to-from)
	for i in range(outputsize):
		var res:float = 0
		for j in range(inputsize):
			res += w[i * inputsize + j] * nextinput[j]
		result[i] = res + b[i]

func forward_by_id(inputs:PackedInt64Array):
	var highest = inputs.duplicate()
	highest.sort()
	highest = highest[0]
	if input < highest:
		printerr("undefined ", highest, " index, the limit is ", input)
		return null
	forward_result = []
	var result:PackedFloat64Array
	var nextinput:PackedFloat64Array
	var w
	var b
	var a
	var inputsize
	var outputsize
	if is_biased:
		w = layers[0]["w"]
		b = layers[0]["b"]
		a = layers[0]["a"]
		inputsize = layers[0]["i"]
		outputsize = layers[0]["o"]
		result.resize(outputsize)
		for i in range(outputsize):
			var res:float = 0.0
			for j in inputs:
				var index = i * inputsize + j
				res += w[index]
			result[i] = res + b[i]
		result = activations(result, a)
		nextinput = result
		forward_result.append(result)
		for layer in range(1, layers.size()):
			w = layers[layer]["w"]
			b = layers[layer]["b"]
			a = layers[layer]["a"]
			inputsize = layers[layer]["i"]
			outputsize = layers[layer]["o"]
			result = []
			result.resize(outputsize)
			for i in range(outputsize):
				var res:float = 0.0
				for j in range(inputsize):
					var index = i * inputsize + j
					res += w[index] * nextinput[j]
				result[i] = res + b[i]
			result = activations(result, a)
			nextinput = result
			forward_result.append(result)
	else:
		w = layers[0]["w"]
		a = layers[0]["a"]
		inputsize = layers[0]["i"]
		outputsize = layers[0]["o"]
		result.resize(outputsize)
		for i in range(outputsize):
			var res:float = 0.0
			for j in inputs:
				var index = i * inputsize + j
				res += w[index]
			result[i] = res
		result = activations(result, a)
		nextinput = result
		forward_result.append(result)
		for layer in range(1, layers.size()):
			w = layers[layer]["w"]
			a = layers[layer]["a"]
			inputsize = layers[layer]["i"]
			outputsize = layers[layer]["o"]
			result = []
			result.resize(outputsize)
			for i in range(outputsize):
				var res:float = 0.0
				for j in range(inputsize):
					var index = i * inputsize + j
					res += w[index] * nextinput[j]
				result[i] = res
			result = activations(result, a)
			nextinput = result
			forward_result.append(result)
	return forward_result.back()

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

func backward_by_id(inputs:PackedInt64Array, expected:PackedFloat64Array, count:int = 1000, rate:float = 0.01):
	var highest = inputs.duplicate()
	highest.sort()
	highest = highest[0]
	if input < highest:
		printerr("undefined ", highest, " index, the limit is ", input)
		return null
	if layers.back()["o"] != expected.size():
		printerr("expected ", layers.back()["o"], " output but given ", expected.size())
		return null
	if is_biased:
		_backward_by_id_bias(inputs, expected, count, rate)
	else:
		_backward_by_id_nobias(inputs, expected, count, rate)

func backward_many(inputs:Array[PackedFloat64Array], expecteds:Array[PackedFloat64Array], count:int = 1000, rate:float = 0.01):
	if inputs.size() != expecteds.size():
		printerr("expected ", inputs.size(), " but given ", expecteds.size())
		return null
	if layers.front()["i"] != inputs[0].size():
		printerr("expected ", layers.front()["i"], " input but given ", inputs.size())
		return null
	if layers.back()["o"] != expecteds[0].size():
		printerr("expected ", layers.back()["o"], " output but given ", expecteds[0].size())
		return null
	if is_biased:
		_backward_many_bias(inputs, expecteds, count, rate)
	else:
		_backward_many_nobias(inputs, expecteds, count, rate)

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
	if layers.size() == 1:
		error = []
		error.resize(outputsize)
		simplecode.resize(outputsize)
		thisinput = inputs
		for repeat in range(count):
			#input layer
			inputsize = layers[0]["i"]
			outputsize = layers[0]["o"]
			w = layers[0]["w"]
			b = layers[0]["b"]
			derivatives = derivative_activations(forward_result[0], a)
			for o in range(outputsize):
				error[o] = (forward_result[-1][o] - expected[o])
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
					b[o] -= simplecode[o]
	else:
		for repeat in range(count):
				###################################################
				#output layer
				forward(inputs)
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
	if layers.size() == 1:
		error = []
		error.resize(outputsize)
		simplecode.resize(outputsize)
		thisinput = inputs
		for repeat in range(count):
			#input layer
			inputsize = layers[0]["i"]
			outputsize = layers[0]["o"]
			w = layers[0]["w"]
			derivatives = derivative_activations(forward_result[0], a)
			for o in range(outputsize):
				error[o] = (forward_result[-1][o] - expected[o])
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
	else:
		for repeat in range(count):
			###################################################
			#output layer
			forward(inputs)
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

func _backward_by_id_bias(inputs:PackedInt64Array, expected:PackedFloat64Array, count:int = 1000, rate:float = 0.01):
	var inputsize = layers.back()["i"]
	var inputlen:int = 0
	var outputsize = layers.back()["o"]
	var w = layers.back()["w"]
	var b = layers.back()["b"]
	var a = layers.back()["a"]
	
	var error:PackedFloat64Array = []
	var futureerror:PackedFloat64Array = []
	var simplecode:PackedFloat64Array = []
	var thisinput = []
	var derivatives:PackedFloat64Array = []
	if layers.size() == 1:
		printerr("not fixed 458")
		error = []
		error.resize(outputsize)
		simplecode.resize(outputsize)
		thisinput = inputs
		for repeat in range(count):
			#input layer
			forward_by_id(inputs)
			inputsize = layers[0]["i"]
			outputsize = layers[0]["o"]
			w = layers[0]["w"]
			b = layers[0]["b"]
			derivatives = derivative_activations(forward_result[0], a)
			for o in range(outputsize):
				error[o] = (forward_result[-1][o] - expected[o])
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
					b[o] -= simplecode[o]
	else:
		for repeat in range(count):
			###################################################
			#output layer
			forward_by_id(inputs)
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
			inputsize = inputs.size()
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
					w[o * inputs[i] + i] -= simplecode[o] * 1
					b[o] -= simplecode[o]

func _backward_by_id_nobias(inputs:PackedInt64Array, expected:PackedFloat64Array, count:int = 1000, rate:float = 0.01):
	var inputsize = layers.back()["i"]
	var inputlen:int = 0
	var outputsize = layers.back()["o"]
	var w = layers.back()["w"]
	var a = layers.back()["a"]
	
	var error:PackedFloat64Array = []
	var futureerror:PackedFloat64Array = []
	var simplecode:PackedFloat64Array = []
	var thisinput = []
	var derivatives:PackedFloat64Array = []
	if layers.size() == 1:
		error = []
		error.resize(outputsize)
		simplecode.resize(outputsize)
		thisinput = inputs
		inputlen = layers[0]["i"]
		inputsize = inputs.size()
		outputsize = layers[0]["o"]
		w = layers[0]["w"]
		for repeat in range(count):
			#input layer
			derivatives = derivative_activations(forward_result[-1], a)
			for o in range(outputsize):
				error[o] = (forward_result[-1][o] - expected[o])
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					w[o * inputlen + inputs[i]] -= simplecode[o] * 1
	else:
		for repeat in range(count):
			###################################################
			#output layer
			forward_by_id(inputs)
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
			print(forward_result[-1])
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
			inputsize = inputs.size()
			inputlen = layers[0]["i"]
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
					w[o * inputlen + inputs[i]] -= simplecode[o] * 1

func _backward_many_bias(inputs:Array[PackedFloat64Array], expecteds:Array[PackedFloat64Array], count:int = 1000, rate:float = 0.01):
	var repeat = inputs.size()
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
	for rep in range(repeat, count + repeat):
			var id = rep % repeat
			###################################################
			#output layer
			forward(inputs[id])
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
			for o in range(outputsize):
				error[o] = (forward_result[-1][o] - expecteds[id][o])
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
			thisinput = inputs[id]
			derivatives = derivative_activations(forward_result[0], a)
			for o in range(outputsize):
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
					b[o] -= simplecode[o]

func _backward_many_nobias(inputs:Array[PackedFloat64Array], expecteds:Array[PackedFloat64Array], count:int = 1000, rate:float = 0.01):
	var repeat = inputs.size()
	var inputsize = layers.back()["i"]
	var outputsize = layers.back()["o"]
	var w = layers.back()["w"]
	var a = layers.back()["a"]
	
	var error:PackedFloat64Array = []
	var futureerror:PackedFloat64Array = []
	var simplecode:PackedFloat64Array = []
	var thisinput:PackedFloat64Array = []
	var derivatives:PackedFloat64Array = []
	if layers.size() == 1:
		error = []
		error.resize(outputsize)
		simplecode.resize(outputsize)
		thisinput = inputs
		inputsize = layers[0]["i"]
		outputsize = layers[0]["o"]
		for rep in range(repeat, count + repeat):
			var id = rep % repeat
			
			#input layer
			thisinput = inputs[id]
			forward(thisinput)
			w = layers[0]["w"]
			derivatives = derivative_activations(forward_result[0], a)
			for o in range(outputsize):
				error[o] = (forward_result[-1][o] - expecteds[id][o])
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
	else:
		for rep in range(repeat, count + repeat):
			var id = rep % repeat
			###################################################
			#output layer
			forward(inputs[id])
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
			for o in range(outputsize):
				error[o] = (forward_result[-1][o] - expecteds[id][o])
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
			thisinput = inputs[id]
			derivatives = derivative_activations(forward_result[0], a)
			for o in range(outputsize):
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					w[o * inputsize + i] -= simplecode[o] * thisinput[i]

func _train_with_error(inputs:PackedFloat64Array, errors:PackedFloat64Array, rate:float = 0.01):
	var inputsize = layers.back()["i"]
	var outputsize = layers.back()["o"]
	var w = layers.back()["w"]
	var b = layers.back()["b"]
	var a = layers.back()["a"]
#	print("error original ", errors)
	var error:PackedFloat64Array = []
	var futureerror:PackedFloat64Array = []
	var simplecode:PackedFloat64Array = []
	var thisinput:PackedFloat64Array = []
	var derivatives:PackedFloat64Array = []
#	print("errors top", errors)
	if layers.size() == 1:
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
#			print("errors ", errors)
			inputsize = layers[0]["i"]
			outputsize = layers[0]["o"]
#			w = layers[0]["w"]
			a = layers[0]["a"]
#			error = errors
#			futureerror = []
#			futureerror.resize(inputsize)
			simplecode.resize(outputsize)
#			thisinput = inputs
#			derivatives = derivative_activations(forward_result[-1], a)
#			for o in range(outputsize):
#				simplecode[o] = error[o] * derivatives[o]
#
#			for i in range(inputsize):
#				for o in range(outputsize):
#					futureerror[i] += simplecode[o] * w[o * inputsize + i]
#					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
	#		print(error)
			
			####################################################
			#input layer
#			inputsize = layers[0]["i"]
#			outputsize = layers[0]["o"]
			w = layers[0]["w"]
			error = errors
			futureerror = []
			futureerror.resize(inputsize)
			simplecode.resize(outputsize)
			thisinput = inputs
			derivatives = derivative_activations(forward_result[0], a)
#			print("error ", error)
			for o in range(outputsize):
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					futureerror[i] += simplecode[o] * w[o * inputsize + i]
					w[o * inputsize + i] -= simplecode[o] * thisinput[i] * rate
	# more than 1 layer
	else:
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

func _train_many_with_error(inputs:Array, errors:Array, rate:float = 0.01):
	var inputsize = layers.back()["i"]
	var outputsize = layers.back()["o"]
	var w = layers.back()["w"]
	var b = layers.back()["b"]
	var a = layers.back()["a"]
#	print("error original ", errors)
	var error:PackedFloat64Array = []
	var futureerror:PackedFloat64Array = []
	var simplecode:PackedFloat64Array = []
	var thisinput:PackedFloat64Array = []
	var derivatives:PackedFloat64Array = []
#	print("errors top", errors)
	if layers.size() == 1:
		if is_biased:
			printerr("not fixed")
			return
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
			var repeat = inputs.size()
			for rep in repeat:
				inputsize = layers[0]["i"]
				outputsize = layers[0]["o"]
				w = layers[0]["w"]
				a = layers[0]["a"]
				####################################################
				#input layer
				error = errors[rep]
				futureerror = []
				futureerror.resize(inputsize)
				simplecode.resize(outputsize)
				thisinput = inputs[rep]
				derivatives = derivative_activations(forward_result[0], a)
	#			print("error ", error)
				for o in range(outputsize):
					simplecode[o] = error[o] * derivatives[o]
				
				for i in range(inputsize):
					for o in range(outputsize):
#						futureerror[i] += simplecode[o] * w[o * inputsize + i]
						w[o * inputsize + i] -= simplecode[o] * thisinput[i] * rate
	# more than 1 layer
	else:
		printerr("not fixed")
		return
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

func _train_many_by_id_with_error(inputs:PackedInt64Array, errors:Array, rate:float = 0.01):
	var inputsize = layers.back()["i"]
	var outputsize = layers.back()["o"]
	var w = layers.back()["w"]
	var b = layers.back()["b"]
	var a = layers.back()["a"]
#	print("error original ", errors)
	var error:PackedFloat64Array = []
	var futureerror:PackedFloat64Array = []
	var simplecode:PackedFloat64Array = []
	var thisinput:int
	var derivatives:PackedFloat64Array = []
#	print("errors top", errors)
	if layers.size() == 1:
		if is_biased:
			printerr("not fixed")
			return
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
#					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
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
#						w[o * inputsize + i] -= simplecode[o] * thisinput[i]
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
#			thisinput = inputs #error
			derivatives = derivative_activations(forward_result[0], a)
			for o in range(outputsize):
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					futureerror[i] += simplecode[o] * w[o * inputsize + i]
#					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
					b[o] -= simplecode[o]
		else:
			"""fixed"""
			var repeat = inputs.size()
			for rep in repeat:
				inputsize = layers[0]["i"]
				outputsize = layers[0]["o"]
				w = layers[0]["w"]
				a = layers[0]["a"]
				####################################################
				#input layer
				error = errors[rep]
				futureerror = []
				futureerror.resize(inputsize)
				simplecode.resize(outputsize)
				thisinput = inputs[rep]
				derivatives = derivative_activations(forward_result[0], a)
	#			print("error ", error)
				for o in range(outputsize):
					simplecode[o] = error[o] * derivatives[o]
				
#				for i in range(inputsize):
				for o in range(outputsize):
#						futureerror[i] += simplecode[o] * w[o * inputsize + i]
					w[o * inputsize + thisinput] -= simplecode[o] * rate
	# more than 1 layer
	else:
		printerr("not fixed")
		return
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
#					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
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
#						w[o * inputsize + i] -= simplecode[o] * thisinput[i]
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
#			thisinput = inputs #error
			derivatives = derivative_activations(forward_result[0], a)
			for o in range(outputsize):
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					futureerror[i] += simplecode[o] * w[o * inputsize + i]
#					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
					b[o] -= simplecode[o]
		else:
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
#					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
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
#						w[o * inputsize + i] -= simplecode[o] * thisinput[i]
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
#			thisinput = inputs #error
			derivatives = derivative_activations(forward_result[0], a)
			for o in range(outputsize):
				simplecode[o] = error[o] * derivatives[o]
			
			for i in range(inputsize):
				for o in range(outputsize):
					futureerror[i] += simplecode[o] * w[o * inputsize + i]
#					w[o * inputsize + i] -= simplecode[o] * thisinput[i]
	return futureerror

func _train_many_with_expected(inputs:Array, expecteds:Array):
	var repeat:int = inputs.size()
	var inputsize = layers.back()["i"]
	var outputsize = layers.back()["o"]
	var w = layers.back()["w"]
	var b = layers.back()["b"]
	var a = layers.back()["a"]
	
	var error:PackedFloat64Array = []
	var futureerror:PackedFloat64Array = []
	var futureerrors:Array = []
	var simplecode:PackedFloat64Array = []
	var thisinput:PackedFloat64Array = []
	var derivatives:PackedFloat64Array = []
	
	if is_biased:
		inputsize = layers[-1]["i"]
		outputsize = layers[-1]["o"]
		w = layers[-1]["w"]
		b = layers[-1]["b"]
		a = layers[-1]["a"]
		
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
		if layers.size() == 1:
			futureerrors.resize(repeat)
			simplecode.resize(outputsize)
			error.resize(outputsize)
			
			for rep in range(repeat):
				forward(inputs[rep])
				futureerror = []
				futureerror.resize(inputsize)
				derivatives = derivative_activations(forward_result[0], a)
				for o in range(outputsize):
					error[o] = (forward_result[-1][o] - expecteds[rep][o])
					simplecode[o] = error[o] * derivatives[o]
				for i in range(inputsize):
					for o in range(outputsize):
						futureerror[i] += simplecode[o] * w[o * inputsize + i]
				futureerrors[rep] = futureerror
			
			for rep in range(repeat):
				#input layer
				forward(inputs[rep])
				inputsize = layers[0]["i"]
				outputsize = layers[0]["o"]
				w = layers[0]["w"]
				futureerror = []
				futureerror.resize(inputsize)
				thisinput = inputs[rep]
				derivatives = derivative_activations(forward_result[0], a)
				for o in range(outputsize):
					error[o] = (forward_result[-1][o] - expecteds[rep][o])
					simplecode[o] = error[o] * derivatives[o]
				
				for i in range(inputsize):
					for o in range(outputsize):
						w[o * inputsize + i] -= simplecode[o] * thisinput[i]
		else:
			for rep in range(repeat):
				forward(inputs[rep])
				inputsize = layers[-1]["i"]
				outputsize = layers[-1]["o"]
				w = layers[-1]["w"]
				a = layers[-1]["a"]
				
				futureerror = []
				futureerror.resize(inputsize)
				simplecode.resize(outputsize)
				thisinput = forward_result[-2]
				derivatives = derivative_activations(forward_result[-1], a)
				for o in range(outputsize):
					error[o] = (forward_result[-1][o] - expecteds[rep][o])
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
	return futureerrors

func _train_many_with_expected_transpose(inputs:Array, expecteds:Array):
	var repeat:int = inputs.size()
	var inputsize = layers.back()["i"]
	var outputsize = layers.back()["o"]
	var w = layers.back()["w"]
	var b = layers.back()["b"]
	var a = layers.back()["a"]
	
	var error:PackedFloat64Array = []
	var futureerror:PackedFloat64Array = []
	var futureerrors:Array = []
	var simplecode:PackedFloat64Array = []
	var thisinput:PackedFloat64Array = []
	var derivatives:PackedFloat64Array = []
	
	if is_biased:
		printerr("false code")
		return null
		inputsize = layers[-1]["i"]
		outputsize = layers[-1]["o"]
		w = layers[-1]["w"]
		b = layers[-1]["b"]
		a = layers[-1]["a"]
		
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
		if layers.size() == 1:
			var futureerror2:float
			futureerrors.resize(inputsize)
			simplecode.resize(outputsize)
			error.resize(outputsize)
			
			for rep in range(inputsize):
				var array:Array = []
				array.resize(repeat)
				futureerrors[rep] = array
			
			for rep in range(repeat):
				forward(inputs[rep])
				futureerror = []
				futureerror.resize(inputsize)
				derivatives = derivative_activations(forward_result[0], a)
				for o in range(outputsize):
					error[o] = (forward_result[-1][o] - expecteds[rep][o])
					simplecode[o] = error[o] * derivatives[o]
				for i in range(inputsize):
					futureerror2 = 0.0
					for o in range(outputsize):
						futureerror2 += simplecode[o] * w[o * inputsize + i]
					futureerrors[i][rep] = futureerror2
			
			for rep in range(repeat):
				#input layer
				forward(inputs[rep])
				inputsize = layers[0]["i"]
				outputsize = layers[0]["o"]
				w = layers[0]["w"]
				futureerror = []
				futureerror.resize(inputsize)
				thisinput = inputs[rep]
				derivatives = derivative_activations(forward_result[0], a)
				for o in range(outputsize):
					error[o] = (forward_result[-1][o] - expecteds[rep][o])
					simplecode[o] = error[o] * derivatives[o]
				
				for i in range(inputsize):
					for o in range(outputsize):
						w[o * inputsize + i] -= simplecode[o] * thisinput[i]
		else:
			printerr("false code")
			return null
			for rep in range(repeat):
				forward(inputs[rep])
				inputsize = layers[-1]["i"]
				outputsize = layers[-1]["o"]
				w = layers[-1]["w"]
				a = layers[-1]["a"]
				
				futureerror = []
				futureerror.resize(inputsize)
				simplecode.resize(outputsize)
				thisinput = forward_result[-2]
				derivatives = derivative_activations(forward_result[-1], a)
				for o in range(outputsize):
					error[o] = (forward_result[-1][o] - expecteds[rep][o])
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
	return futureerrors

func activationcr3r(number:float, type:ACTIVATION):
	match type:
		ACTIVATION.TANH:
			return tanh(number)
		ACTIVATION.SIGMOID:
			return (1 / (1 + pow(E, -number)))
		ACTIVATION.NONE:
			return number

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


#
#func derivative_activation(number:float, type:ACTIVATION):
#	return (1 - pow(number, 2))

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

func softmax(numbers:PackedFloat64Array):
	var size = numbers.size()
	var exp:PackedFloat64Array
	var total:float = 0.0
	exp.resize(size)
	for e in range(size):
		var res = pow(E, numbers[e])
		exp[e] = res
		total += res
	for e in range(size):
		exp[e] /= total
	return exp

func _to_dictionary()->Dictionary:
	var data:Dictionary = {}
	data["is_biased"] = is_biased
	data["input"] = input
	data["layers"] = layers
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
	is_biased = data["is_biased"]
	input = data["input"]
	layers = data["layers"]
