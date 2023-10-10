extends RefCounted
class_name Transformer2

var wem:WEM2
var VectorSize:int
var Layer:Array[Coder2]

func _init():
	wem = WEM2.new()

func init(vector_size:int, layer_size:int = 1, head_size:int = 2, sequence_length:int = 10):
	VectorSize = vector_size
	if (vector_size % head_size) != 0:
		printerr("invalid head size!")
		return null
	Layer.resize(layer_size)
	for i in range(layer_size):
		Layer[i] = Coder2.new().init(vector_size, head_size)
	wem.init(vector_size, sequence_length)
	return self

func save(_path:String):
	var f = FileAccess.open(_path, FileAccess.WRITE)
	var layer:Array
	layer.resize(Layer.size())
	for i in range(Layer.size()):
		layer[i] = Layer[i].to_dict()
	if wem.is_empty():
		f.store_string(
			JSON.stringify(
				{
					"layer" : layer
				},
				"\t", false, true
			)
		)
	else:
		f.store_string(
			JSON.stringify(
				{
					"layer" : layer,
					"wem": wem.to_dict()
				},
				"\t", false, true
			)
		)
	f.close()

func load(_path:String):
	var f = FileAccess.open(_path, FileAccess.READ)
	var data = JSON.parse_string(
		f.get_as_text()
	)
	f.close()
	var layer:Array = data["layer"]
	Layer.resize(layer.size())
	
	for i in range(layer.size()):
		Layer[i] = Coder2.init_from_dict(layer[i])
	VectorSize = Layer[0].Vector_size
	if data.has("wem"):
		wem = WEM2.init_from_dict(data["wem"])
	
	return self

func forward(input:Matrix):
	var result = input
#	print("input ", input, "\n")
	for c in range(Layer.size()):
		result = Layer[c].forward(result)
#		print("forward of ", c, " ", result, "\n")
	
	return result

func forward_fast(input:Matrix):
	var result = input
#	print("input ", input, "\n")
	for c in range(Layer.size()):
		result = Layer[c].forward_fast(result)
#		print("forward of ", c, " ", result, "\n")
	
	return result

func forward_s(input:String):
	return forward(
		wem.forward_sentence(input)
	)

func forward_sentence_to_sentence(input:String):
	return wem.backward_sentence(
		forward(
			wem.forward_sentence(input)
		)
	) 

func learn_coder(error:Matrix, rate:float = 0.1/pow(VectorSize, 2.0)):
	for c in range(Layer.size()-1, -1, -1):
#		print("error ", error, "\n")
		error = Layer[c].__learn(error, rate)
#		Layer[c].learn(error, rate)
	return error

func learn_s(input_s:String, expected_s:String):
	var input = wem.forward_sentence(input_s)
	var expected = wem.sentence_to_ids(expected_s)
	var result1 = forward(input)
	var output = wem.backward(result1)
	
	var result2 = wem.rectify_backward(output, expected)
	var transformer_learn = wem.learn_backward(result1, result2)
	learn_coder(transformer_learn)
