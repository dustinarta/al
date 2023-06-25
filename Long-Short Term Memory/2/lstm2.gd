extends RefCounted
class_name LSTM2


const E = 2.7181828459

var path:String
var weights:PackedFloat64Array
var biases:PackedFloat64Array
var stm:PackedFloat64Array
var ltm:PackedFloat64Array
var forward_result:Array
var forward_input:Array

func _init():
	pass

func init():
	weights.resize(8)
	biases.resize(4)
	init_weight_and_bias()
	init_memory()
	return self

func init_weight_and_bias():
	for i in range(8):
		weights[i] = randf_range(-1.0, 1.0)
	for i in range(4):
		biases[i] = randf_range(-1.0, 1.0)

func init_memory(l:float = 0.01, s:float = 0.01):
	ltm = [l]
	stm = [s]
	forward_result = []

func get_output():
	return stm.slice(1)

func forward(input:float):
	var results:PackedFloat64Array
	var last_stm = stm[-1]
	
	results.resize(5)
	last_stm = stm[-1]
	results[0] = sigmoid( input * weights[0] + last_stm * weights[1] + biases[0] )
	ltm.append(ltm[-1] * results[0])
	results[1] = sigmoid( input * weights[2] + last_stm * weights[3] + biases[1] )
	results[2] = tanh( input * weights[4] + last_stm * weights[5] + biases[2] )
	ltm[-1] += results[1] * results[2]
	results[3] = sigmoid( input * weights[6] + last_stm * weights[7] + biases[3] )
	results[4] = tanh( ltm[-1] )
	stm.append( results[3] * results[4] )
	
	forward_result.append(results)
	forward_input.append(input)
	
	return stm[-1]

func forward_many(inputs:PackedFloat64Array):
	var repeat = inputs.size()
	var results:PackedFloat64Array
	var last_stm = stm[-1]
	
	results.resize(5)
	for rep in range(repeat):
		var input = inputs[rep]
		last_stm = stm[-1]
		results[0] = sigmoid( input * weights[0] + last_stm * weights[1] + biases[0] )
		ltm.append(ltm[-1] * results[0])
		results[1] = sigmoid( input * weights[2] + last_stm * weights[3] + biases[1] )
		results[2] = tanh( input * weights[4] + last_stm * weights[5] + biases[2] )
		ltm[-1] += results[1] * results[2]
		results[3] = sigmoid( input * weights[6] + last_stm * weights[7] + biases[3] )
		results[4] = tanh( ltm[-1] )
		stm.append( results[3] * results[4] )
		forward_result.append(results)
		forward_input.append(input)
	
	return stm[-1]

func train_with_expected(input:float, expected:float, rate:float = 0.1):
	var output:float
	var error:float
	var res
	var res0
	var res1
	var res2
	var res3
	var res4
	
	
	init_memory()
	output = forward(input)
	error = expected - output
	res = forward_result[0]
	res0 = res[0]
	res1 = res[1]
	res2 = res[2]
	res3 = res[3]
	res4 = res[4]
	var last_stm = stm[-2]
	var simplecodecode = (1 - pow( ltm[-1], 2 ) ) * error * res3
	var simplecode1 = res4 * error * ((1 - res3) * res3) * rate
	weights[6] += simplecode1 * input
	weights[7] += simplecode1 * last_stm
	biases[3] += simplecode1
	var simplecode2 = simplecodecode * res1 * (1 - pow(res2, 2)) * rate
	weights[4] += simplecode2 * input
	weights[5] += simplecode2 * last_stm
	biases[2] += simplecode2
	var simplecode3 = simplecodecode * res2 * ((1 - (res1)) * res1) * rate
	weights[2] += simplecode3 * input
	weights[3] += simplecode3 * last_stm
	biases[1] += simplecode3
	var simplecode4 = simplecodecode * ltm[-2] * ((1 - (res0)) * res0) * rate
	weights[0] += simplecode4 * input
	weights[1] += simplecode4 * last_stm
	biases[0] += simplecode4

func train_with_error(input:float, error:float, rate:float = 0.1):
	var res
	var res0
	var res1
	var res2
	var res3
	var res4
	
	init_memory()
	forward(input)
	res = forward_result[-1]
	res0 = res[0]
	res1 = res[1]
	res2 = res[2]
	res3 = res[3]
	res4 = res[4]
	var last_stm = stm[-2]
	var simplecodecode = (1 - pow( ltm[-1], 2 ) ) * error * res3
	var simplecode1 = res[4] * error * ((1 - res3) * res3) * rate
	weights[6] += simplecode1 * input
	weights[7] += simplecode1 * last_stm
	biases[3] += simplecode1
	var simplecode2 = simplecodecode * res1 * (1 - pow(res2, 2)) * rate
	weights[4] += simplecode2 * input
	weights[5] += simplecode2 * last_stm
	biases[2] += simplecode2
	var simplecode3 = simplecodecode * res2 * ((1 - res1) * res1) * rate
	weights[2] += simplecode3 * input
	weights[3] += simplecode3 * last_stm
	biases[1] += simplecode3
	var simplecode4 = simplecodecode * ltm[-2] * ((1 - res0) * res0) * rate
	weights[0] += simplecode4 * input
	weights[1] += simplecode4 * last_stm
	biases[0] += simplecode4

func train_now_with_error(error:float, rate:float = 0.1):
	var res
	var res0
	var res1
	var res2
	var res3
	var res4
	var input
	
	input = forward_input[-1]
	res = forward_result[-1]
	res0 = res[0]
	res1 = res[1]
	res2 = res[2]
	res3 = res[3]
	res4 = res[4]
	var last_stm = stm[-2]
	var simplecodecode = (1 - pow( ltm[-1], 2 ) ) * error * res3
	var simplecode1 = res[4] * error * ((1 - res3) * res3) * rate
	weights[6] += simplecode1 * input
	weights[7] += simplecode1 * last_stm
	biases[3] += simplecode1
	var simplecode2 = simplecodecode * res1 * (1 - pow(res2, 2)) * rate
	weights[4] += simplecode2 * input
	weights[5] += simplecode2 * last_stm
	biases[2] += simplecode2
	var simplecode3 = simplecodecode * res2 * ((1 - res1) * res1) * rate
	weights[2] += simplecode3 * input
	weights[3] += simplecode3 * last_stm
	biases[1] += simplecode3
	var simplecode4 = simplecodecode * ltm[-2] * ((1 - res0) * res0) * rate
	weights[0] += simplecode4 * input
	weights[1] += simplecode4 * last_stm
	biases[0] += simplecode4

func train_now_with_many_error(errors:PackedFloat64Array, rate:float = 0.1):
	if errors.size() != forward_input.size():
		printerr("invalid size!")
		return null
	
	var repeat = forward_input.size()
	var res
	var res0
	var res1
	var res2
	var res3
	var res4
	var input
	var error:float
	
	for rep in range(repeat-1, -1, -1):
		input = forward_input[rep]
		error = errors[rep]
		res = forward_result[rep]
		res0 = res[0]
		res1 = res[1]
		res2 = res[2]
		res3 = res[3]
		res4 = res[4]
		var last_stm = stm[rep-1]
		var simplecodecode = (1 - pow( ltm[rep], 2 ) ) * error * res3
		var simplecode1 = res[4] * error * ((1 - res3) * res3) * rate
		weights[6] += simplecode1 * input
		weights[7] += simplecode1 * last_stm
		biases[3] += simplecode1
		var simplecode2 = simplecodecode * res1 * (1 - pow(res2, 2)) * rate
		weights[4] += simplecode2 * input
		weights[5] += simplecode2 * last_stm
		biases[2] += simplecode2
		var simplecode3 = simplecodecode * res2 * ((1 - res1) * res1) * rate
		weights[2] += simplecode3 * input
		weights[3] += simplecode3 * last_stm
		biases[1] += simplecode3
		var simplecode4 = simplecodecode * ltm[rep-1] * ((1 - res0) * res0) * rate
		weights[0] += simplecode4 * input
		weights[1] += simplecode4 * last_stm
		biases[0] += simplecode4


func calculate_all_error_with_error_for_stm(error:float):
	var repeat:int = forward_input.size()
	var futureerrors:PackedFloat64Array
	var res
	var res0
	var res1
	var res2
	var res3
	var res4
	
	futureerrors.resize(repeat+1)
	futureerrors[-1] = error
	
	for rep in range(repeat-1, -1, -1):
		res = forward_result[rep]
		res0 = res[0]
		res1 = res[1]
		res2 = res[2]
		res3 = res[3]
		res4 = res[4]
		var futureerror:float = 0.0
		var last_stm = stm[rep-1]
		var simplecodecode = (1 - pow( ltm[rep], 2 ) ) * error * res3
		var simplecode1 = res[4] * error * ((1 - res3) * res3)
		futureerror += simplecode1 * weights[7]
		var simplecode2 = simplecodecode * res1 * (1 - pow(res2, 2))
		futureerror += simplecode2 * weights[5]
		var simplecode3 = simplecodecode * res2 * ((1 - res1) * res1)
		futureerror += simplecode3 * weights[3]
		var simplecode4 = simplecodecode * ltm[rep-1] * ((1 - res0) * res0)
		futureerror += simplecode4 * weights[1]
		error = futureerror
		futureerrors[rep] = futureerror
	return futureerrors

func calculate_all_error_with_error_for_input(error:float):
	var repeat:int = forward_input.size()
	var futureerrors:PackedFloat64Array
	var res
	var res0
	var res1
	var res2
	var res3
	var res4
	
	futureerrors.resize(repeat+1)
	futureerrors[-1] = error
	
	for rep in range(repeat-1, -1, -1):
		res = forward_result[rep]
		res0 = res[0]
		res1 = res[1]
		res2 = res[2]
		res3 = res[3]
		res4 = res[4]
		var futureerror:float = 0.0
		var last_stm = stm[rep-1]
		var simplecodecode = (1 - pow( ltm[rep], 2 ) ) * error * res3
		var simplecode1 = res[4] * error * ((1 - res3) * res3)
		futureerror += simplecode1 * weights[6]
		var simplecode2 = simplecodecode * res1 * (1 - pow(res2, 2))
		futureerror += simplecode2 * weights[4]
		var simplecode3 = simplecodecode * res2 * ((1 - res1) * res1)
		futureerror += simplecode3 * weights[2]
		var simplecode4 = simplecodecode * ltm[rep-1] * ((1 - res0) * res0)
		futureerror += simplecode4 * weights[0]
		error = futureerror
		futureerrors[rep] = futureerror
	return futureerrors

func sigmoid(x:float):
	return 1/(1 + pow(2.7172, -x))
