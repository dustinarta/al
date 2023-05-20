extends RefCounted
class_name NN2

const EULER = 2.71828

var layers:Array[Layer]
var allneuron:Array[Neuron]

func _init(layer:Layer):
	if layer == null:
		printerr("Expected layer!")
	else:
		layers.append(layer)

func forward(inputs:PackedFloat64Array):
	var firstlayer:Layer = layers[0]
	var firstlayerneurons = firstlayer.neurons
	
	for i in range(firstlayer.size()):
		firstlayerneurons[i].input = inputs[i]
#		print(firstlayerneurons[i].input)
#	print(firstlayer)
	
	for i in range(layers.size()-1):
		var thislayer = layers[i]
		var thislayerneurons = thislayer.neurons
#		print(thislayer)
#		print(thislayer.all_input())
#		print(thislayer.size())
		thislayer.activate()
		for j in range(thislayer.size()):
			thislayerneurons[j].compute()
	
	var output:PackedFloat64Array
#	print(layers[-1].all_input())
	layers[-1].activate()
#	print(layers[-1].all_input())
	var lastlayerneurons:Array[Neuron] = layers[-1].neurons
	for i in range(lastlayerneurons.size()):
		output.append(lastlayerneurons[i].input)
	return output

func add_layer(count:int, activation:ActivationType = ActivationType.none):
	var prevlayer:Layer = layers.back()
	var thislayer:Layer
	var thislayerneurons:Array[Neuron]
	if count > 0:
		thislayer = Layer.new(count, activation)
		thislayer.is_output = true
		layers.append(thislayer)
		allneuron.append_array(thislayer.neurons)
	else:
		printerr("Invalid count! ", count)
	
	thislayerneurons = thislayer.neurons
	if layers.size() > 0:
		var prevneurons:Array[Neuron] = prevlayer.neurons
#		print("add ", prevlayer.size())
		for j in range(prevlayer.size()):
			for i in range(count):
				prevneurons[j].connection.append([randf_range(-2.0, 2.0), thislayerneurons[i]])

class Neuron:
	var input:float
	var bias:float
	var connection:Array
	
	func _init(bias:float = 0.0):
		self.bias = bias
	
	func compute():
#		print(connection)
		for i in range(connection.size()):
			var w = connection[i][0]
			var target = connection[i][1]
			target.input += w * input
#			print("neuron ", self, "w ", w, " input ", input)

class Layer:
	var neurons:Array[Neuron]
	var activationtype:ActivationType
	var is_output:bool
	
	func _init(count:int, activation:ActivationType = ActivationType.none):
		for i in range(count):
			var n = Neuron.new(randf())
			neurons.append(n)
		activationtype = activation
	
	func activate():
#		print("before")
#		for n in neurons:
#			print(n.input)
		match activationtype:
			ActivationType.tanh:
				for n in neurons:
					n.input = tanh(n.input)
			ActivationType.max:
				for n in neurons:
					if n.input <= 0:
						n.input = 0
			ActivationType.sigmoid:
				for n in neurons:
					n.input = 1/(1 + pow(EULER, -n.input))
			ActivationType.softmax:
				var es:PackedFloat64Array
				var esum:float = 0.0
				for n in neurons:
					var this_e = pow(EULER, n.input)
					es.append(this_e)
					esum += this_e
				for n in range(neurons.size()):
					neurons[n].input = es[n]/esum
				
#		print("after")
#		for n in neurons:
#			print(n.input)
	
	func all_input():
		var result:PackedFloat64Array
		for n in neurons:
			result.append(n.input)
		return result
	
	func size()->int:
		return neurons.size()

enum ActivationType {
	none = 0,
	softmax,
	sigmoid,
	tanh,
	max,
	min,
}
