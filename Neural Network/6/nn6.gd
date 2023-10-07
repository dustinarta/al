extends RefCounted
class_name NN6

var InputCount:int
var LayerSize:int
var Activations:PackedInt64Array
var Layers:Array[Matrix]
var IsBiassed:bool
var Biasses:Array[Matrix]

enum ACTIVATIONS {
	none,
	tanh,
	sigmoid,
	softmax
}

func _init():
	pass

func init(input_count:int, layers:PackedInt64Array, is_biassed:bool = true):
	var layer_size = layers.size()
	LayerSize = layer_size
	Layers.resize(layer_size)
	var input:int = input_count
	
	for i in range(layers.size()):
		Layers[i] = Matrix.new().init(input_count, layers[i]).self_randomize(-1.0, 1.0)
		input_count = layers[i]
	
	IsBiassed = is_biassed
	if is_biassed:
		Biasses.resize(layer_size)
		
		for i in range(layer_size):
			Biasses[i] = Matrix.new().init(1, layers[i]).self_randomize(-1.0, 1.0)

func save(_path:String):
	pass

func forward(input:PackedFloat64Array):
	return _forward(Matrix.new().fill_force([input]))

func _forward(_input:Matrix):
	var result:Matrix = _input
	if IsBiassed:
		for l in range(Layers.size()):
			result = result.mul(Layers[l]).add_self(Biasses[l])
	else:
		for l in range(Layers.size()):
			result = result.mul(Layers[l])
	return result

func to_dict()->Dictionary:
	var layers:Array
	layers.resize(LayerSize)
	for i in range(LayerSize):
		layers[i] = Layers[i].to_dict()
	var biasses:Array
	biasses.resize(LayerSize)
	for i in range(LayerSize):
		biasses[i] = Biasses[i].to_dict()
	return {
		"input_count": InputCount,
		"layer_size": LayerSize,
		"is_biassed": IsBiassed,
		"activations": Activations,
		"layers": layers,
		"biasses": biasses
	}
