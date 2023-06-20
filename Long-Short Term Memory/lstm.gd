@tool
extends RefCounted
class_name LSTM


const E = 2.7181828459

var path:String
var weights:Array
var biases:PackedFloat64Array
var stm:PackedFloat64Array
var ltm:PackedFloat64Array
var forward_result:Array
var accuracy:float

var _test_mode:bool = false

func _init():
	pass

func init():
	weights.resize(4)
	biases.resize(4)
	init_weight_and_bias()
	init_memory()
	return self

func init_weight_and_bias():
	if _test_mode:
		for i in range(4):
			weights[i] = [0.5, 0.5]
		for i in range(4):
			biases[i] = 0.5
	else:
		for i in range(4):
			weights[i] = [randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)] as PackedFloat64Array
		for i in range(4):
			biases[i] = randf_range(-1, 1)

func init_memory(l:float = 0.01, s:float = 0.01):
	ltm = [l]
	stm = [s]
	forward_result = []

func get_ltm_and_stm():
	return [ltm, stm]

func get_stm():
	return stm

func get_output():
	return stm[-1]

func _forward(input:float, ltm:PackedFloat64Array = [], stm:PackedFloat64Array = []):
	var results:PackedFloat64Array = [0.0, 0.0, 0.0, 0.0]
	if ltm.is_empty() or stm.is_empty():
		results[0] = sigmoid( input * weights[0][0] + self.stm[-1] * weights[0][1] + biases[0] )
		self.ltm.append(self.ltm[-1] * results[0])
		results[1] = sigmoid( input * weights[1][0] + self.stm[-1] * weights[1][1] + biases[1] )
		results[2] = tanh( input * weights[2][0] + self.stm[-1] * weights[2][1] + biases[2] )
		self.ltm[-1] += results[1] * results[2]
		results[3] = sigmoid( input * weights[3][0] + self.stm[-1] * weights[3][1] + biases[3] )
		self.stm.append( results[3] * tanh( self.ltm[-1] ) )
	else:
		results[0] = sigmoid( input * weights[0][0] + stm[-1] * weights[0][1] + biases[0] )
		ltm.append(ltm[-1] * results[0])
		results[1] = sigmoid( input * weights[1][0] + stm[-1] * weights[1][1] + biases[1] )
		results[2] = tanh( input * weights[2][0] + stm[-1] * weights[2][1] + biases[2] )
		ltm[-1] += results[1] * results[2]
		results[3] = sigmoid( input * weights[3][0] + stm[-1] * weights[3][1] + biases[3] )
		stm.append( results[3] * tanh( ltm[-1] ) )
	return results

func forward(inputs:PackedFloat64Array):
	var results:Array[PackedFloat64Array]
	for i in range(inputs.size()):
		results.append(_forward(inputs[i]))
	forward_result.append_array(results)
	return results

#forward but reset the memory
func forward2(inputs:PackedFloat64Array):
	init_memory()
	var results:Array[PackedFloat64Array]
	for i in range(inputs.size()):
		results.append(_forward(inputs[i]))
	forward_result.append_array(results)
	return results

func sigmoid(x:float):
	return 1/(1 + pow(2.7172, -x))

func backward(inputs:PackedFloat64Array, expected:float, count:int = 100, rate:float = 0.01):
	var repeat:int = inputs.size()
	var result
	var error
	rate = rate / repeat
	for c in range(count):
		var oldltm = ltm.duplicate()
		var oldstm = stm.duplicate()
		init_memory()
		result = forward(inputs)
		error = (stm[-1] - expected)
		var res = result[-1]
		var simplecodecode = (1 - pow( ltm[-1], 2 ) ) * error * res[3]
		var simplecode1 = tanh(ltm[-1]) * error * ((1 - res[3]) * res[3]) * rate
		weights[3][0] -= simplecode1 * inputs[0]
		weights[3][1] -= simplecode1 * stm[-2]
		biases[3] -= simplecode1
		var simplecode2 = simplecodecode * res[1] * (1 - pow(res[2], 2)) * rate
		weights[2][0] -= simplecode2 * inputs[0]
		weights[2][1] -= simplecode2 * stm[-2]
		biases[2] -= simplecode2
		var simplecode3 = simplecodecode * res[2] * ((1 - (res[1])) * res[1]) * rate
		weights[1][0] -= simplecode3 * inputs[0]
		weights[1][1] -= simplecode3 * stm[-2]
		biases[1] -= simplecode3
		var simplecode4 = simplecodecode * ltm[-2] * ((1 - (res[0])) * res[0]) * rate
		weights[0][0] -= simplecode4 * inputs[0]
		weights[0][1] -= simplecode4 * stm[-2]
		biases[0] -= simplecode4
		
		for rep in range(repeat-2, -1, -1):
			var newltm:PackedFloat64Array = [oldltm[rep]]
			var newstm:PackedFloat64Array = [oldstm[rep]]
			res = _forward(inputs[rep], newltm, newstm)
			error = (newstm[1] - oldstm[rep])
			var simplecodecode2 = (1 - pow( newltm[1], 2 ) ) * error * res[3]
			var simplecode21 = tanh(newltm[1]) * error * ((1 - res[3]) * res[3]) * rate
			weights[3][0] -= simplecode21 * inputs[rep]
			weights[3][1] -= simplecode21 * newstm[0]
			biases[3] -= simplecode21
			var simplecode22 = simplecodecode2 * res[1] * (1 - pow(res[2], 2)) * rate
			weights[2][0] -= simplecode22 * inputs[rep]
			weights[2][1] -= simplecode22 * newstm[0]
			biases[2] -= simplecode22
			var simplecode23 = simplecodecode2 * res[2] * ((1 - (res[1])) * res[1]) * rate
			weights[1][0] -= simplecode23 * inputs[rep]
			weights[1][1] -= simplecode23 * newstm[0]
			biases[1] -= simplecode23
			var simplecode24 = simplecodecode2 * newltm[0] * ((1 - (res[0])) * res[0]) * rate
			weights[0][0] -= simplecode24 * inputs[rep]
			weights[0][1] -= simplecode24 * newstm[0]
			biases[0] -= simplecode24

func backward2(inputs:PackedFloat64Array, expected:float, count:int = 100, rate:float = 0.01):
	var repeat:int = inputs.size()
	var result
	var error
	for c in range(count):
		init_memory()
		result = forward(inputs)
		error = (stm[-1] - expected)
		var res = result[-1]
		var expected2 = expected
		for rep in range(repeat-1, -1, -1):
			res = result[rep]
			error = (stm[rep+1] - expected2)
			var simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
			var simplecode21 = tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * rate
			weights[3][0] -= simplecode21 * inputs[rep]
			weights[3][1] -= simplecode21 * stm[rep]
			biases[3] -= simplecode21
			var simplecode22 = simplecodecode  * res[1] * (1 - pow(res[2], 2)) * rate
			weights[2][0] -= simplecode22 * inputs[rep]
			weights[2][1] -= simplecode22 * stm[rep]
			biases[2] -= simplecode22
			var simplecode23 = simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * rate
			weights[1][0] -= simplecode23 * inputs[rep]
			weights[1][1] -= simplecode23 * stm[rep]
			biases[1] -= simplecode23
			var simplecode24 = simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * rate
			weights[0][0] -= simplecode24 * inputs[rep]
			weights[0][1] -= simplecode24 * stm[rep]
			biases[0] -= simplecode24
			
			expected2 = stm[rep]

func backward3(inputs:PackedFloat64Array, expected:float, count:int = 100, rate:float = 0.01):
	var repeat:int = inputs.size()
	var result
	var error
	var futureerror
	for c in range(count):
		init_memory()
		result = forward(inputs)
		error = (stm[-1] - expected)
		var res = result[-1]
		var expected2 = expected
		
		futureerror = (stm[-1] - expected2)
		
		for rep in range(repeat-1, 0, -1):
			res = result[rep]
			var simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
			futureerror += tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * weights[3][1]
			futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][1]
			futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][1]
			futureerror += simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * weights[0][1]
			error = futureerror
			futureerror = 0
		
		var simplecodecode = (1 - pow( ltm[1], 2 ) ) * error * res[3]
		var simplecode21 = tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * rate
		weights[3][0] -= simplecode21 * inputs[0]
		weights[3][1] -= simplecode21 * stm[0]
		biases[3] -= simplecode21
		var simplecode22 = simplecodecode  * res[1] * (1 - pow(res[2], 2)) * rate
		weights[2][0] -= simplecode22 * inputs[0]
		weights[2][1] -= simplecode22 * stm[0]
		biases[2] -= simplecode22
		var simplecode23 = simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * rate
		weights[1][0] -= simplecode23 * inputs[0]
		weights[1][1] -= simplecode23 * stm[0]
		biases[1] -= simplecode23
		var simplecode24 = simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * rate
		weights[0][0] -= simplecode24 * inputs[0]
		weights[0][1] -= simplecode24 * stm[0]
		biases[0] -= simplecode24
		
		expected2 = stm[0]

func backward_many(inputs:PackedFloat64Array, expecteds:PackedFloat64Array, count:int = 100, rate:float = 0.01):
	var repeat:int = inputs.size()
	var result
	var error
	if inputs.size() != expecteds.size():
		printerr("Expected ", inputs.size(), " but given ", expecteds.size())
		return
	
	for c in range(count):
		result = forward2(inputs)
		var res
		for rep in range(repeat-1, -1, -1):
			res = result[rep]
			error = (stm[rep+1] - expecteds[rep])
#			print(error)
#			print(stm[rep+1], " - ", expecteds[rep], " = ",  error)
			var simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
			var simplecode21 = tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * rate
			weights[3][0] -= simplecode21 * inputs[rep]
			weights[3][1] -= simplecode21 * stm[rep]
			biases[3] -= simplecode21
			var simplecode22 = simplecodecode  * res[1] * (1 - pow(res[2], 2)) * rate
			weights[2][0] -= simplecode22 * inputs[rep]
			weights[2][1] -= simplecode22 * stm[rep]
			biases[2] -= simplecode22
			var simplecode23 = simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * rate
			weights[1][0] -= simplecode23 * inputs[rep]
			weights[1][1] -= simplecode23 * stm[rep]
			biases[1] -= simplecode23
			var simplecode24 = simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * rate
			weights[0][0] -= simplecode24 * inputs[rep]
			weights[0][1] -= simplecode24 * stm[rep]
			biases[0] -= simplecode24
	init_memory()

func backward2_many(inputs:PackedFloat64Array, expecteds:PackedFloat64Array, count:int = 100, rate:float = 0.01):
	var repeat:int = inputs.size()
	var result
	var error
	var futureerror
	if inputs.size() != expecteds.size():
		printerr("Expected ", inputs.size(), " but given ", expecteds.size())
		return
	
	for c in range(count):
		result = forward2(inputs)
		error = 0.0
		futureerror = 0.0
		var res
		for rep in range(repeat-1, -1, -1):
			res = result[rep]
			error = (stm[rep+1] - expecteds[rep]) + futureerror
#			print(error)
#			print(stm[rep+1], " - ", expecteds[rep], " = ",  error)
			var simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
			var simplecode21 = tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * rate
			var simplecode22 = simplecodecode  * res[1] * (1 - pow(res[2], 2)) * rate
			var simplecode23 = simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * rate
			var simplecode24 = simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * rate
			
			futureerror += simplecode21 * weights[3][1]
			futureerror += simplecode22 * weights[2][1]
			futureerror += simplecode23 * weights[1][1]
			futureerror += simplecode24 * weights[0][1]
			
			
			weights[3][0] -= simplecode21 * inputs[rep]
			weights[3][1] -= simplecode21 * stm[rep]
			biases[3] -= simplecode21
			weights[2][0] -= simplecode22 * inputs[rep]
			weights[2][1] -= simplecode22 * stm[rep]
			biases[2] -= simplecode22
			weights[1][0] -= simplecode23 * inputs[rep]
			weights[1][1] -= simplecode23 * stm[rep]
			biases[1] -= simplecode23
			weights[0][0] -= simplecode24 * inputs[rep]
			weights[0][1] -= simplecode24 * stm[rep]
			biases[0] -= simplecode24
			
	init_memory()

func _train_now_many_once_with_error(inputs:PackedFloat64Array, errors:PackedFloat64Array, rate:float = 0.01, memory:PackedFloat64Array = []):
	var repeat:int = inputs.size()
	var result
	var futureerror:float = 0.0
	var error
	var res
	var simplecodecode
	
	for rep in range(repeat-1, -1, -1):
		error = errors[rep]
#		print(rep, errors)
#		print(error)
		res = forward_result[rep]
		simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
		var simplecode21 = tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * rate
		var simplecode22 = simplecodecode  * res[1] * (1 - pow(res[2], 2)) * rate
		var simplecode23 = simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * rate
		var simplecode24 = simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * rate
		
		weights[3][0] -= simplecode21 * inputs[rep]
		weights[3][1] -= simplecode21 * stm[rep]
		biases[3] -= simplecode21
		weights[2][0] -= simplecode22 * inputs[rep]
		weights[2][1] -= simplecode22 * stm[rep]
		biases[2] -= simplecode22
		weights[1][0] -= simplecode23 * inputs[rep]
		weights[1][1] -= simplecode23 * stm[rep]
		biases[1] -= simplecode23
		weights[0][0] -= simplecode24 * inputs[rep]
		weights[0][1] -= simplecode24 * stm[rep]
		biases[0] -= simplecode24
		
		if rep == 0:
			futureerror += simplecode21 * weights[3][1]
			futureerror += simplecode21 * weights[2][1]
			futureerror += simplecode21 * weights[1][1]
			futureerror += simplecode21 * weights[0][1]
		
	return futureerror

func _train_now_many_with_error(inputs:PackedFloat64Array, errors:PackedFloat64Array, count:int = 100, rate:float = 0.01, memory:PackedFloat64Array = []):
	var repeat:int = inputs.size()
	var result
	var futureerror:float
	var error
	var res
	var simplecodecode
	
	for c in range(count):
		forward2(inputs)
		for rep in range(repeat-1, -1, -1):
			error = errors[rep]
			res = forward_result[rep]
			futureerror = 0.0
			simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
			futureerror += tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * weights[3][1]
			futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][1]
			futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][1]
			futureerror += simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * weights[0][1]
			error = futureerror
			futureerror = 0
			
			var simplecode21 = tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * rate
			weights[3][0] -= simplecode21 * inputs[rep]
			weights[3][1] -= simplecode21 * stm[rep]
			biases[3] -= simplecode21
			var simplecode22 = simplecodecode  * res[rep] * (1 - pow(res[2], 2)) * rate
			weights[2][0] -= simplecode22 * inputs[rep]
			weights[2][1] -= simplecode22 * stm[rep]
			biases[2] -= simplecode22
			var simplecode23 = simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * rate
			weights[1][0] -= simplecode23 * inputs[rep]
			weights[1][1] -= simplecode23 * stm[rep]
			biases[1] -= simplecode23
			var simplecode24 = simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * rate
			weights[0][0] -= simplecode24 * inputs[rep]
			weights[0][1] -= simplecode24 * stm[rep]
			biases[0] -= simplecode24

func _train_with_error(inputs:PackedFloat64Array, error:float, rate:float = 0.01, memory:Array = []):
	"""
	Using backward3 algorithm
	"""
	var stm
	var ltm
	
	if memory.size() != 0:
		stm = memory[0]
		ltm = memory[1]
	else:
		stm = self.stm
		ltm = self.ltm
	
	var repeat:int = inputs.size()
	if stm.size()-1 != repeat:
		printerr("invalid memory and input size!")
		return null
	
	var futureerror
	forward(inputs)
	var res = forward_result[-1]
	var simplecodecode
	
	for rep in range(repeat-1, 0, -1):
		res = forward_result[rep]
		simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
		futureerror += tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * weights[3][1]
		futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][1]
		futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][1]
		futureerror += simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * weights[0][1]
		error = futureerror
		futureerror = 0
	
	simplecodecode = (1 - pow( ltm[1], 2 ) ) * error * res[3]
	futureerror += tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * weights[3][1]
	futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][1]
	futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][1]
	futureerror += simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * weights[0][1]
	
	var simplecode21 = tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * rate
	weights[3][0] -= simplecode21 * inputs[0]
	weights[3][1] -= simplecode21 * stm[0]
	biases[3] -= simplecode21
	var simplecode22 = simplecodecode  * res[1] * (1 - pow(res[2], 2)) * rate
	weights[2][0] -= simplecode22 * inputs[0]
	weights[2][1] -= simplecode22 * stm[0]
	biases[2] -= simplecode22
	var simplecode23 = simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * rate
	weights[1][0] -= simplecode23 * inputs[0]
	weights[1][1] -= simplecode23 * stm[0]
	biases[1] -= simplecode23
	var simplecode24 = simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * rate
	weights[0][0] -= simplecode24 * inputs[0]
	weights[0][1] -= simplecode24 * stm[0]
	biases[0] -= simplecode24
	
	return futureerror

func _train_with_error_get_input_error(inputs:PackedFloat64Array, error:float, rate:float = 0.01, memory:Array = []):
	"""
	Using backward3 algorithm
	"""
	var stm
	var ltm
	
	if memory.size() != 0:
		stm = memory[0]
		ltm = memory[1]
	else:
		stm = self.stm
		ltm = self.ltm
	
	var repeat:int = inputs.size()
	if stm.size()-1 != repeat:
		printerr("invalid memory and input size! memory: ", stm.size()-1, " input: ", repeat)
		return null
	
	var futureerror:float = 0.0
	var futureerrors:Array
	futureerrors.resize(repeat)
#	forward(inputs)
	var res = forward_result[-1]
	var simplecodecode
#	print(forward_result)
	var train_weight = weights.duplicate(true)
	
	for rep in range(repeat-1, 0, -1):
		
		res = forward_result[rep]
		simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
		futureerror = 0.0
		futureerror += tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * train_weight[3][0]
		futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * train_weight[2][0]
		futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * train_weight[1][0]
		futureerror += simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * train_weight[0][0]
		futureerrors[rep] = futureerror
		var simplecode21 = tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * rate
		weights[3][0] -= simplecode21 * inputs[rep]
		weights[3][1] -= simplecode21 * stm[rep]
		biases[3] -= simplecode21
		var simplecode22 = simplecodecode  * res[1] * (1 - pow(res[2], 2)) * rate
		weights[2][0] -= simplecode22 * inputs[rep]
		weights[2][1] -= simplecode22 * stm[rep]
		biases[2] -= simplecode22
		var simplecode23 = simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * rate
		weights[1][0] -= simplecode23 * inputs[rep]
		weights[1][1] -= simplecode23 * stm[rep]
		biases[1] -= simplecode23
		var simplecode24 = simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * rate
		weights[0][0] -= simplecode24 * inputs[rep]
		weights[0][1] -= simplecode24 * stm[rep]
		biases[0] -= simplecode24
		futureerror = 0.0
		futureerror += tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * train_weight[3][1]
		futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * train_weight[2][1]
		futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * train_weight[1][1]
		futureerror += simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * train_weight[0][1]
		error = futureerror
		
	res = forward_result[0]
	simplecodecode = (1 - pow( ltm[1], 2 ) ) * error * res[3]
	futureerror = 0.0
	futureerror += tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * train_weight[3][0]
	futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * train_weight[2][0]
	futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * train_weight[1][0]
	futureerror += simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * train_weight[0][0]
	futureerrors[0] = futureerror
	var simplecode21 = tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * rate
	weights[3][0] -= simplecode21 * inputs[0]
	weights[3][1] -= simplecode21 * stm[0]
	biases[3] -= simplecode21
	var simplecode22 = simplecodecode  * res[1] * (1 - pow(res[2], 2)) * rate
	weights[2][0] -= simplecode22 * inputs[0]
	weights[2][1] -= simplecode22 * stm[0]
	biases[2] -= simplecode22
	var simplecode23 = simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * rate
	weights[1][0] -= simplecode23 * inputs[0]
	weights[1][1] -= simplecode23 * stm[0]
	biases[1] -= simplecode23
	var simplecode24 = simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * rate
	weights[0][0] -= simplecode24 * inputs[0]
	weights[0][1] -= simplecode24 * stm[0]
	biases[0] -= simplecode24
#
#	simplecodecode = (1 - pow( ltm[1], 2 ) ) * error * res[3]
#	futureerror += tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * weights[3][1]
#	futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][1]
#	futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][1]
#	futureerror += simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * weights[0][1]
#
	
	
	return futureerrors

func _train_with_errors_get_input_error(inputs:PackedFloat64Array, errors:PackedFloat64Array, rate:float = 0.01, memory:Array = []):
	"""
	Using backward3 algorithm
	"""
	var stm
	var ltm
	
	if memory.size() != 0:
		stm = memory[0]
		ltm = memory[1]
	else:
		stm = self.stm
		ltm = self.ltm
	var error = 0.0
	var repeat:int = inputs.size()
	if stm.size()-1 != repeat:
		printerr("invalid memory and input size! memory: ", stm.size()-1, " input: ", repeat)
		return null
	
	var futureerror:float = 0.0
	var futureerrors:Array
	futureerrors.resize(repeat)
#	forward(inputs)
	var res = forward_result[-1]
	var simplecodecode
#	print(forward_result)
	var train_weight = weights.duplicate(true)
	
	for rep in range(repeat-1, 0, -1):
		error = errors[rep]
		res = forward_result[rep]
		simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
		futureerror = 0.0
		futureerror += tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * train_weight[3][0]
		futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * train_weight[2][0]
		futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * train_weight[1][0]
		futureerror += simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * train_weight[0][0]
		futureerrors[rep] = futureerror
		var simplecode21 = tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * rate
		weights[3][0] -= simplecode21 * inputs[rep]
		weights[3][1] -= simplecode21 * stm[rep]
		biases[3] -= simplecode21
		var simplecode22 = simplecodecode  * res[1] * (1 - pow(res[2], 2)) * rate
		weights[2][0] -= simplecode22 * inputs[rep]
		weights[2][1] -= simplecode22 * stm[rep]
		biases[2] -= simplecode22
		var simplecode23 = simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * rate
		weights[1][0] -= simplecode23 * inputs[rep]
		weights[1][1] -= simplecode23 * stm[rep]
		biases[1] -= simplecode23
		var simplecode24 = simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * rate
		weights[0][0] -= simplecode24 * inputs[rep]
		weights[0][1] -= simplecode24 * stm[rep]
		biases[0] -= simplecode24
	error = errors[0]
	res = forward_result[0]
	simplecodecode = (1 - pow( ltm[1], 2 ) ) * error * res[3]
	futureerror = 0.0
	futureerror += tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * train_weight[3][0]
	futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * train_weight[2][0]
	futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * train_weight[1][0]
	futureerror += simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * train_weight[0][0]
	futureerrors[0] = futureerror
	var simplecode21 = tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * rate
	weights[3][0] -= simplecode21 * inputs[0]
	weights[3][1] -= simplecode21 * stm[0]
	biases[3] -= simplecode21
	var simplecode22 = simplecodecode  * res[1] * (1 - pow(res[2], 2)) * rate
	weights[2][0] -= simplecode22 * inputs[0]
	weights[2][1] -= simplecode22 * stm[0]
	biases[2] -= simplecode22
	var simplecode23 = simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * rate
	weights[1][0] -= simplecode23 * inputs[0]
	weights[1][1] -= simplecode23 * stm[0]
	biases[1] -= simplecode23
	var simplecode24 = simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * rate
	weights[0][0] -= simplecode24 * inputs[0]
	weights[0][1] -= simplecode24 * stm[0]
	biases[0] -= simplecode24
#
#	simplecodecode = (1 - pow( ltm[1], 2 ) ) * error * res[3]
#	futureerror += tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * weights[3][1]
#	futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][1]
#	futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][1]
#	futureerror += simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * weights[0][1]
#
	
	
	return futureerrors

#
#func _train_many_with_error(inputs:Array[PackedFloat64Array], errors:PackedFloat64Array, rate:float = 0.01):
#	"""
#	Using backward3 algorithm
#	"""
#
#	var repeat:int = inputs.size()
#	var result
#	var futureerror
#	init_memory()
#	result = forward(inputs)
#	var res = result[-1]
#	var simplecodecode
#
#	for rep in range(repeat-1, 0, -1):
#		res = result[rep]
#		simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
#		futureerror += tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * weights[3][1]
#		futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][1]
#		futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][1]
#		futureerror += simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * weights[0][1]
#		error = futureerror
#		futureerror = 0
#
#	simplecodecode = (1 - pow( ltm[1], 2 ) ) * error * res[3]
#	futureerror += tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * weights[3][1]
#	futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][1]
#	futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][1]
#	futureerror += simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * weights[0][1]
#
#	simplecodecode = (1 - pow( ltm[1], 2 ) ) * error * res[3]
#	var simplecode21 = tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * rate
#	weights[3][0] -= simplecode21 * inputs[0]
#	weights[3][1] -= simplecode21 * stm[0]
#	biases[3] -= simplecode21
#	var simplecode22 = simplecodecode  * res[1] * (1 - pow(res[2], 2)) * rate
#	weights[2][0] -= simplecode22 * inputs[0]
#	weights[2][1] -= simplecode22 * stm[0]
#	biases[2] -= simplecode22
#	var simplecode23 = simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * rate
#	weights[1][0] -= simplecode23 * inputs[0]
#	weights[1][1] -= simplecode23 * stm[0]
#	biases[1] -= simplecode23
#	var simplecode24 = simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * rate
#	weights[0][0] -= simplecode24 * inputs[0]
#	weights[0][1] -= simplecode24 * stm[0]
#	biases[0] -= simplecode24
#
#	return futureerror

func get_error_for_stm_with_error(error:float)->float:
	var futureerror:float = 0.0
	var res = forward_result[-1]
	var simplecodecode = (1 - pow( ltm[1], 2 ) ) * error * res[3]
	futureerror += tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * weights[3][1]
	futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][1]
	futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][1]
	futureerror += simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * weights[0][1]
	return futureerror

func get_error_for_input_with_error(error:float)->float:
	var futureerror:float = 0.0
	var res = forward_result[-1]
	var simplecodecode = (1 - pow( ltm[1], 2 ) ) * error * res[3]
	futureerror += tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * weights[3][0]
	futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][0]
	futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][0]
	futureerror += simplecodecode * ltm[0] * ((1 - (res[0])) * res[0]) * weights[0][0]
	return futureerror

#func get_total_error_for_stm_with_error(error:float)->float:
#	var repeat:int = stm.size()-1
#	var futureerrors:PackedFloat64Array
#	var futureerror:float = 0.0
#	var res
#	var simplecodecode:float
#	for rep in range(repeat-1, -1, -1):
#		futureerror = 0.0
#		res = forward_result[rep]
#		simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
#		futureerror += tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * weights[3][1]
#		futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][1]
#		futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][1]
#		futureerror += simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * weights[0][1]
#		error = futureerror
#	return error

func get_total_error_for_stm_with_errors(errors:PackedFloat64Array)->float:
	var repeat:int = stm.size()-1
	var futureerrors:PackedFloat64Array
	var futureerror:float = 0.0
	var error:float = 0.0
	var res
	var simplecodecode:float
	for rep in range(repeat-1, -1, -1):
		error = errors[rep] + futureerror
		futureerror = 0.0
		res = forward_result[rep]
		simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
		futureerror += tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * weights[3][1]
		futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][1]
		futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][1]
		futureerror += simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * weights[0][1]
	return error

func get_all_error_for_stm_with_error(error:float)->PackedFloat64Array:
	var repeat:int = stm.size()-1
	var futureerrors:PackedFloat64Array
	var futureerror:float = 0.0
	var res
	var simplecodecode:float
	for rep in range(repeat-1, -1, -1):
		futureerror = 0.0
		res = forward_result[rep]
		simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
		futureerror += tanh(ltm[rep+1]) * error * ((1 - res[3]) * res[3]) * weights[3][1]
		futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][1]
		futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][1]
		futureerror += simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * weights[0][1]
		futureerrors.append(futureerror)
		error = futureerror
	return futureerrors

func get_all_error_for_input_with_errors(errors:PackedFloat64Array)->PackedFloat64Array:
	var repeat:int = stm.size()-1
	var futureerrors:PackedFloat64Array = []
	var futureerror:float = 0.0
	var error:float
	var w
	var res = forward_result[-1]
	var simplecodecode
	for rep in range(repeat-1, -1, -1):
		res = forward_result[rep]
		error = errors[rep]
		simplecodecode = (1 - pow( ltm[rep+1], 2 ) ) * error * res[3]
		futureerror += tanh(ltm[1]) * error * ((1 - res[3]) * res[3]) * weights[3][0]
		futureerror += simplecodecode  * res[1] * (1 - pow(res[2], 2)) * weights[2][0]
		futureerror += simplecodecode  * res[2] * ((1 - (res[1])) * res[1]) * weights[1][0]
		futureerror += simplecodecode * ltm[rep] * ((1 - (res[0])) * res[0]) * weights[0][0]
		futureerrors[rep] = futureerror
	return futureerrors

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
	data["weights"] = weights
	data["biases"] = biases
	return data

func save(path:String = self.path):
	FileAccess.open(path, FileAccess.WRITE).store_string(
		JSON.stringify(self._to_dictionary(), "\t")
	)

func load(path:String = self.path):
	var data = JSON.parse_string(
		FileAccess.open(path, FileAccess.READ).get_as_text()
	)
	self.path = path
	load_from_dict(data)

func load_from_dict(data:Dictionary):
	weights = data["weights"]
	biases = data["biases"]

func _to_string():
	var s:String
	s += \
"""Input gate [{w1}, {w2}][{b1}]
Forget gate [{w3}, {w4}, {w5}, {w6}][{b2}, {b3}]
Output gate [{w7}, {w8}][{b4}]""".format({
		w1 = weights[0][0],
		w2 = weights[0][1],
		w3 = weights[1][0],
		w4 = weights[1][1],
		w5 = weights[2][0],
		w6 = weights[2][1],
		w7 = weights[3][1],
		w8 = weights[3][1],
		b1 = biases[0],
		b2 = biases[1],
		b3 = biases[2],
		b4 = biases[3]
	})
	return s
