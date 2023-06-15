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
		cells[c] = LSTM.new().init()

func forward(inputs:Array):
	if inputs.size() != cell_count:
		printerr("Invalid input count! expected ", cell_count, " but given ", inputs.size())
		return null
	print(inputs)
	var inputsize = inputs[0].size()
	print("nani")
	for i in range(1, inputs.size()):
		if inputs[i].size() != inputsize:
			printerr("Invalid input size! expected ", inputsize, " but given ", inputs[i].size())
			return null
	init_all()
	var results:Array
	results.resize(cell_count)
	for c in range(cell_count):
		print("haiya")
		results[c] = cells[c].forward(inputs[c])
	return results

func forward_col(inputs:Array):
	var size = inputs.size()
	var length = inputs[0].size()
	if length != cell_count:
		printerr("Invalid input count! expected ", cell_count, " but given ", inputs.size())
		return null
	for i in range(1, size):
		if inputs[i].size() != length:
			printerr("Invalid input count! expected ", length, " but given ", inputs[i].size())
			return null
	init_all()
	var results:Array
	results.resize(cell_count)
	for c in range(size):
		for i in range(length):
			results[i] = cells[i].forward([inputs[c][i]])
	
	return results

func get_ltm_and_stm():
	var all:Array
	all.resize(cell_count)
	for c in range(cell_count):
		all[c] = cells[c].get_ltm_and_stm()
	return all

func move_memory(multilstm:MultiLSTM):
	if self.cell_count != multilstm.cell_count:
		printerr("expected same cell count!")
		return null
	for c in range(cell_count):
		self.cells[c].init_memory(multilstm.cells[c].ltm[-1], multilstm.cells[c].stm[-1])

func init_all():
	for c in cells:
		c.init_memory()

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
	init(cell_count)
	var cells:Array = data["cells"]
	for c in range(cell_count):
		self.cells[c].load_from_dict(cells[c])
