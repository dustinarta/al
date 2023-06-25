extends RefCounted
class_name MultiLayerLSTM

var layers:Array
var layer_count:int

func _init():
	pass

func init(layercount, cellcount):
	self.layer_count = layercount
	layers.resize(layercount)
	
	for i in range(layercount):
		layers[i] = MultiLSTM.new().init(cellcount)
	return self

func forward(inputs:Array):
	pass

func get_output():
	pass
