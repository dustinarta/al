@tool
extends RefCounted
class_name LSTM

var weights:Array
var biases:PackedFloat64Array
var stm:PackedFloat64Array
var ltm:PackedFloat64Array
var functionresult:PackedFloat64Array
var accuracy:float

func _init():
	weights.resize(4)
	biases.resize(4)
	init()

func init():
	for i in range(4):
		weights[i] = [randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)] as PackedFloat64Array
	for i in range(4):
		biases[i] = randf_range(-1, 1)

func init_memory(s:float = 0.1, l:float = 0.1):
	stm = [s]
	ltm = [l]

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
	rate = rate / repeat
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
	rate = rate / repeat
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

func _train_with_error(errors:PackedFloat64Array):
	pass

func save(path:String):
	FileAccess.open(path, FileAccess.WRITE).store_string(
		JSON.stringify(
			{
				"weights" : weights,
				"biases" : biases,
				"last" : accuracy
			}, "\t"
		)
	)
	print("updated")

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
