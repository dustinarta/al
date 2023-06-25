extends RefCounted
class_name MultiLSTM2


var path:String
var cells:Array
var cell_count:int

func _init():
	pass

func init(count:int):
	cell_count = count
	cells.resize(count)
	for c in range(cell_count):
		cells[c] = LSTM2.new().init()
	return self

func restart_memory():
	for cell in cells:
		cell.init_memory()

func forward(inputs:PackedFloat64Array):
	if inputs.size() != cell_count:
		printerr("Invalid input count! expected ", cell_count, " but given ", inputs.size())
		return null
	
	var results:Array
	results.resize(cell_count)
	for c in range(cell_count):
		results[c] = cells[c].forward(inputs[c])
	return results

func train_with_error(errors:PackedFloat64Array):
	if errors.size() != cell_count:
		printerr("Invalid error count! expected ", cell_count, " but given ", errors.size())
		return null
	
	var results:Array
	results.resize(cell_count)
	for c in range(cell_count):
		results[c] = cells[c].train_now_with_error(errors[c])
	restart_memory()
	return results
