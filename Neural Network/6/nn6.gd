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

func init(config:Dictionary)->NN6:
	InputCount = config["input_count"]
	var layers = config["layers"]
	var is_biassed = config.get("biassed", false)
	var layer_size = layers.size()
	LayerSize = layer_size
	Layers.resize(layer_size)
	var input:int = InputCount
	
	for i in range(layers.size()):
		Layers[i] = Matrix.new().init(input, layers[i]).self_randomize(-1.0, 1.0)
		input = layers[i]
	
	IsBiassed = is_biassed
	if is_biassed:
		Biasses.resize(layer_size)
		for i in range(layer_size):
			Biasses[i] = Matrix.new().init(1, layers[i]).self_randomize(-1.0, 1.0)
	return self

func to_dict()->Dictionary:
	return {
		"input_count": InputCount,
		"layers": Matrix.multi_to_dict(Layers),
		"layer_size": LayerSize,
		"activations": Activations,
		"is_biassed": IsBiassed,
		"biasses": Matrix.multi_to_dict(Biasses),
	}

func save(_path:String):
	var file = FileAccess.open(_path, FileAccess.WRITE)
	file.store_string(
		JSON.stringify(to_dict(), "\t", false, true)
	)
	file.close()

func forward_i(input:PackedInt64Array):
	var result:Matrix = Matrix.new()
	result.data.resize(input.size())
	var layer = Layers[0]
	for i in range(input.size()):
		var id = input[i]
		if id > InputCount:
			printerr("Overflow index!")
			return null
		result.data[i] = layer.data[id]
	return result

func forward_pfa(input:PackedFloat64Array):
	return _forward(Matrix.new().fill_force([input]))

func forward_apfa(input:Array[PackedFloat64Array]):
	return _forward(Matrix.new().fill_force(input))

func forward_m(input:Matrix):
	return _forward(input)

func _forward(_input:Matrix)->Matrix:
	var result:Matrix = _input
	if IsBiassed:
		for l in range(Layers.size()):
			result = result.mul(Layers[l]).self_add_singlerow_to_all(Biasses[l])
	else:
		for l in range(Layers.size()):
			result = result.mul(Layers[l])
	return result

