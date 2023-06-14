extends RefCounted
class_name MultiLSTM

var path:String
var cells:Array
var cell_count:int

func _init():
	pass

func init(count:int):
	cell_count = count
	cells.resize(count)
	for c in range(cell_count):
		cells[c] = LSTM.new()

func forward(inputs:Array[PackedFloat64Array]):
	if inputs.size() != cell_count:
		printerr("Invalid input count! expected ", cell_count, " but given ", inputs.size())
		return null
	var inputsize = inputs[0].size()
	for i in range(1, inputs.size()):
		if inputs[i].size() != inputsize:
			printerr("Invalid input size! expected ", inputsize, " but given ", inputs[i].size())
			return null
	
	var results:Array
	results.resize(cell_count)
	
	for c in range(cell_count):
		results[c] = cells[c].forward(inputs[c])
	
	return results

func _to_dictionary():
	var data:Dictionary = {
		"cell_count" : cell_count
	}
	var cells:Array
	cells.resize(cell_count)
	for c in range(cell_count):
		cells[c] = self.cells[c]._to_dictionary()
	data["cells"] = cells
	return data

func save(path:String = self.path):
	FileAccess.open(path, FileAccess.WRITE).store_string(
		JSON.stringify(_to_dictionary(), "\t")
	)

func load(path:String = self.path):
	var data:Dictionary = JSON.parse_string(
		FileAccess.open(path, FileAccess.READ).get_as_text()
	)

func load_from_dict(data:Dictionary):
	cell_count = data["cell_count"]
	cells.resize(cell_count)
	var cells:Array = data["cells"]
	for c in range(cell_count):
		self.cells[c].load_from_dict(cells[c])
