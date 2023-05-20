extends RefCounted
class_name NN

enum ACTIVATION {
	SIGMOID,
	TANH,
	MAX,
	NONE
}

var name:String
var layers:Array
var input:int

const neuron:Dictionary = {
	"a" : ACTIVATION.SIGMOID,
	"b" : 0,
	"w" : []
}
const e = 2.7181828459

func _init(_input:int, _layers:Array = [], _name:String = ""):
	self.name = _name
	self.input = _input
	if _layers.size() != 0:
		self.layers = _layers.duplicate(true)

func add_layer(count:int, type = ACTIVATION.SIGMOID) -> void:
	var layer = []
	var new_neuron = neuron.duplicate(true)
	new_neuron["a"] = type
	var w = new_neuron["w"]
	
	if layers.size() == 0:
		w.resize(input)
	else:
		w.resize(layers[-1].size())

	w.fill(0.0)
	layer.resize(count)
	for i in range(count):
		layer[i] = new_neuron.duplicate(true)
	layers.append(layer)
	
	"""
	if layers.size() == 0:
		w.resize(input)
		w.fill(0.0)
		layer.resize(count)
		print("w is " + str(w))
		for i in range(count):
			layer[i] = neuron.duplicate(true)
			layer[i]["w"] = w.duplicate(true)

	else:
		w.resize(layers[-1].size())
		w.fill(0.0)
		layer.resize(count)
		for i in range(count):
			layer[i] = neuron.duplicate(true)
			layer[i]["w"] = w.duplicate(true)
	"""

func add_layers(counts:PackedInt64Array, types:PackedInt32Array) -> void:
	
	if (typeof(counts) != TYPE_PACKED_INT64_ARRAY):
		printerr("Layers count must be int")
	elif (typeof(types) != TYPE_PACKED_INT32_ARRAY):
		printerr("Layers type must be int for activation")
	
	var length = counts.size()
	for i in range(length):
		self.add_layer(counts[i], types[i])

#static func create(layer:Array, name:="default") -> NeuralNetwork:
#	var input_count = layer[0][0]["w"].size()
#	var nn = NeuralNetwork.new(name, input_count, layer)
#	return nn

func forward(inputs:Array):
	
	if inputs.size() != input:
		printerr("Expected " + str(input) + " input, but given " + str(inputs.size()))
		return null
	var record = []
	record.append(inputs.duplicate())
	record.append([])
	for j in layers[0]:
		var w = j["w"]
		var point = 0.0
		for i in range(inputs.size()):
			point += inputs[i] * w[i]
		record[1].append( activate( point + j["b"], j["a"] ) )
	
	for k in range(1, layers.size()):
		record.append([])
		for j in layers[k]:
			var w = j["w"]
			var point = 0.0
			for i in range(w.size()):
				point += record[k][i] * w[i]
			record[k+1].append( activate( point + j["b"], j["a"] ) )
	return record

static func activate(point:float, type) -> float:
	match(type):
		ACTIVATION.SIGMOID:
			return 1 / (1 + 1 / pow(e, point))
		ACTIVATION.TANH:
			return tanh(point)
		ACTIVATION.MAX:
			if point > 0.0:
				return point
			else:
				return 0.0
		_:
			return point

static func derivative(point:float, type) -> float:
	match(type):
		ACTIVATION.SIGMOID:
			return point * (1 - point)
		ACTIVATION.TANH:
			return 1 - pow(point, 2)
		ACTIVATION.MAX:
			return 1.0
		_:
			return 1.0

func error_point(inputs:Array, target:Array):
	if target.size() != layers[-1].size():
		printerr("Different size of output: " + str(layers[-1].size()) + ", target: " + str(target.size()))
		return null
	var result = forward(inputs)
	
	if result == null:
		printerr("Failed to forward")
		return null
	
	var errors = []
	errors.resize(layers.size())
	
#	last layer
	var last = result[-1]
	errors[-1] = []
	for i in range(last.size()):
		errors[-1].append(last[i] - target[i])
	
	var last_result = result[-1]
	
#	each layer
	for k in range(layers.size()-2, -1, -1):
#		print("at layer: " + str(k) + " with neuron count: " + str(layers[k].size()))
		errors[k] = []
		last = errors[k+1]
		
#		each neuron
		for j in range(layers[k].size()):
			var error = 0.0
#			print("layer size: " + str(layers[k+1].size()))
#			print("last: " + str(last.size()) + ", last size: " + str(last_result.size()))
			for i in range(layers[k+1].size()):
				var layer = layers[k+1][i]
#				print("layer size: " + str(layers[k+1][i].size()))
				error += (last[i] - layer["b"]) * derivative(last_result[i], layer["a"]) * layer["w"][j]
			errors[k].append(error)
		last_result = errors[k]
	return errors

func error_point2(result:Array, target:Array):
	if target.size() != layers[-1].size():
		printerr("Different size of output: " + str(layers[-1].size()) + ", target: " + str(target.size()))
		return null
	
	if result == null:
		printerr("Failed to forward")
		return null
	
	var errors = []
	errors.resize(layers.size())
	
#	last layer
	var last = result[-1]
	errors[-1] = []
	for i in range(last.size()):
		errors[-1].append(last[i] - target[i])
	
	var last_result = result[-1]
#	each layer
	for k in range(layers.size()-2, -1, -1):
#		print("at layer: " + str(k) + " with neuron count: " + str(layers[k].size()))
		errors[k] = []
		last = errors[k+1]
#		each neuron
		for j in range(layers[k].size()):
			var error = 0.0
#			print("layer size: " + str(layers[k+1].size()))
#			print("last: " + str(last.size()) + ", last size: " + str(last_result.size()))
			for i in range(layers[k+1].size()):
				var layer = layers[k+1][i]
#				print("layer size: " + str(layers[k+1][i].size()))
				error += last[i] * derivative(last_result[i], layer["a"]) * layer["w"][j]
			errors[k].append(error)
		last_result = errors[k]
	return errors

func init_weight(init = "") -> void:
	for k in layers:
		for j in k:
			var w = j["w"]
			for i in range(w.size()):
				w[i] = randf_range(-1.0, 1.0)

func init_bias_all(init: = 0.459) -> void:
	for k in layers:
		for j in k:
			j["b"] = init

func _to_string() -> String:
	var result:String = ""
	result += "{\n"
	
	result += "meta:\n\tname = \"" + name + "\", input = " + str(input) + "\n"
	result += "layers:\n"
	for l in layers:
		result += "\t" + str(l) + "\n"
	result += "}"
	return str(result)

