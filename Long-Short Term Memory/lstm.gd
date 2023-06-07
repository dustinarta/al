@tool
extends RefCounted
class_name LSTM

var weights:Array
var biases:PackedFloat64Array
var stm:PackedFloat64Array
var ltm:PackedFloat64Array
var functionresult:PackedFloat64Array

func _init():
	weights.resize(4)
	biases.resize(4)
	init()

func init():
	for i in range(4):
		weights[i] = [randf_range(-5.0, 5.0), randf_range(-5.0, 5.0)] as PackedFloat64Array
	for i in range(4):
		biases[i] = randf_range(-2, 2)

func init_memory(s:float = 0.1, l:float = 0.1):
	stm = [s]
	ltm = [l]

func _forward(input:float):
	var results:PackedFloat64Array = [0.0, 0.0, 0.0, 0.0]
	
	results[0] = sigmoid( input * weights[0][0] + stm[-1] * weights[0][1] + biases[0] )
	ltm.append(ltm[-1] * results[0])
	results[1] = sigmoid( input * weights[1][0] + stm[-1] * weights[1][1] + biases[1] )
	results[2] = tanh( input * weights[2][0] + stm[-1] * weights[2][1] + biases[2] )
	ltm[-1] += results[1] * results[2]
	results[3] = sigmoid( input * weights[3][0] + stm[-1] * weights[3][1] + biases[3] )
	stm.append( results[3] * tanh( ltm[-1] ) )
	
	return results

func forward(inputs:PackedFloat64Array):
	var result
	for i in range(inputs.size()):
		result = _forward(inputs[i])
	return result

func sigmoid(x:float):
	return 1/(1 + pow(2.7172, -x))

func backward(inputs:PackedFloat64Array, expected:float, count:int = 100, rate:float = 0.01):
	var repeat:int = inputs.size()
	var res = forward(inputs)
	var error
	for c in range(count):
		init_memory()
		res = forward(inputs)
		error = (stm[-1] - expected)
		var simplecode1 = tanh(ltm[-1]) * error * ((1 - res[3]) * res[3]) * rate
		weights[3][0] -= simplecode1 * inputs[0]
		weights[3][1] -= simplecode1 * stm[stm.size()-2]
		biases[3] -= simplecode1
		var simplecode2 = (1 - pow( tanh(ltm[-1]), 2 ) ) * error * res[3] * res[1] * (1 - pow(tanh(res[2]), 2)) * rate
		weights[2][0] -= simplecode2 * inputs[0]
		weights[2][1] -= simplecode2 * stm[stm.size()-2]
		biases[2] -= simplecode2
		var simplecode3 = (1 - pow( tanh(ltm[-1]), 2 ) ) * error * res[3] * res[2] * ((1 - (res[1])) * res[1]) * rate
		weights[1][0] -= simplecode3 * inputs[0]
		weights[1][1] -= simplecode3 * stm[stm.size()-2]
		biases[1] -= simplecode3
		var simplecode4 = (1 - pow( tanh(ltm[-1]), 2 ) ) * error * res[3] * ltm[ltm.size()-2] * ((1 - (res[0])) * res[0]) * rate
		weights[0][0] -= simplecode4 * inputs[0]
		weights[0][1] -= simplecode4 * stm[stm.size()-2]
		biases[0] -= simplecode4
		
		


func _to_string():
	var s:String
	s += "Input gate [{w1}, {w2}]\nForget gate [{w3}, {w4}, {w5}, {w6}]\nOutput gate [{w7}, {w8}]".format({
		w1 = weights[0][0],
		w2 = weights[0][1],
		w3 = weights[1][0],
		w4 = weights[1][1],
		w5 = weights[2][0],
		w6 = weights[2][1],
		w7 = weights[3][1],
		w8 = weights[3][1],
	})
	return s
