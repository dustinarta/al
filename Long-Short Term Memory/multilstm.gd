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
#	print(inputs)
	var inputsize = inputs[0].size()
#	print("nani")
	for i in range(1, inputs.size()):
		if inputs[i].size() != inputsize:
			printerr("Invalid input size! expected ", inputsize, " but given ", inputs[i].size())
			return null
	
	var results:Array
	results.resize(cell_count)
	for c in range(cell_count):
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
	
	var results:Array
	results.resize(cell_count)
	for c in range(size):
		for i in range(length):
			results[i] = cells[i].forward([inputs[c][i]])
	
	return results

#func train_with_error(errors:PackedFloat64Array):
#	for c in range(cell_count):
#		cells[c]

var arg1
var arg2
var arg3
var arg4


func train_with_errors_get_input_error(inputs:Array, errors:Array, rate:float = 0.01, memory:Array = []):
	var ret = []
	if cell_count < 10:
		ret.resize(cell_count)
		for c in range(cell_count):
			ret[c] = cells[c]._train_with_errors_get_input_error(inputs[c], errors[c], rate, memory)
	else:
		var t1 = Thread.new()
		var t2 = Thread.new()
		arg1 = inputs
		arg2 = errors
		arg3 = rate
		arg4 = memory
		t1.start( Callable(self, "_multi_thread1_train_with_errors_get_input_error") )
		t2.start( Callable(self, "_multi_thread2_train_with_errors_get_input_error") )
		var ret1 = t1.wait_to_finish()
		var ret2 = t2.wait_to_finish()
		ret.append_array( ret1 )
		ret.append_array( ret2 )
	return ret

func _multi_thread1_train_with_errors_get_input_error():
	var ret = []
	var at = 0
	ret.resize(cell_count/2)
	for c in range(cell_count/2):
		ret[c] = cells[c+at]._train_with_errors_get_input_error(arg1[c+at], arg2[c+at], arg3, arg4)
	return ret

func _multi_thread2_train_with_errors_get_input_error():
	var ret = []
	var at = cell_count/2
	ret.resize(cell_count/2)
	for c in range(cell_count/2):
		ret[c] = cells[c+at]._train_with_errors_get_input_error(arg1[c+at], arg2[c+at], arg3, arg4)
	return ret

func train_with_error_get_input_error(inputs:Array, errors:Array, rate:float = 0.01, memory:Array = []):
	var ret = []
#	if true:
	if cell_count < 10:
		ret.resize(cell_count)
		for c in range(cell_count):
			ret[c] = cells[c]._train_with_error_get_input_error(inputs[c], errors[c], rate, memory)
	else:
		var t1 = Thread.new()
		var t2 = Thread.new()
		arg1 = inputs
		arg2 = errors
		arg3 = rate
		arg4 = memory
		t1.start( Callable(self, "_multi_thread1_train_with_error_get_input_error") )
		t2.start( Callable(self, "_multi_thread2_train_with_error_get_input_error") )
		var ret1 = t1.wait_to_finish()
		var ret2 = t2.wait_to_finish()
		ret.append_array( ret1 )
		ret.append_array( ret2 )
	return ret

func _multi_thread1_train_with_error_get_input_error():
	var ret = []
	var at = 0
	ret.resize(cell_count/2)
	for c in range(cell_count/2):
		ret[c] = cells[c+at]._train_with_error_get_input_error(arg1[c+at], arg2[c+at], arg3, arg4)
	return ret

func _multi_thread2_train_with_error_get_input_error():
	var ret = []
	var at = cell_count/2
	ret.resize(cell_count/2)
	for c in range(cell_count/2):
		ret[c] = cells[c+at]._train_with_error_get_input_error(arg1[c+at], arg2[c+at], arg3, arg4)
	return ret

func get_ltm_and_stm():
	var all:Array
	all.resize(cell_count)
	for c in range(cell_count):
		all[c] = cells[c].get_ltm_and_stm()
	return all

func get_all_stm():
	var len = cells[0].stm.size()
	var all:Array[PackedFloat64Array]
	all.resize(cell_count)
	
	for j in range(cell_count):
		var arr:PackedFloat64Array = []
		arr.resize(len-1)
		for i in range(1, len):
			arr[i-1] = cells[j].stm[i]
		all[j] = arr
	return all

func get_all_stm_col():
	var len = cells[0].stm.size()
	var all:Array[PackedFloat64Array]
	all.resize(len-1)
	
	for j in range(1, len):
		var arr:PackedFloat64Array = []
		arr.resize(cell_count)
		for i in range(cell_count):
			arr[i] = cells[i].stm[j]
		all[j-1] = arr
	return all

func get_output():
	var outputs:PackedFloat64Array
	outputs.resize(cell_count)
	
	for o in range(cell_count):
		outputs[o] = cells[o].stm[-1]
	return outputs

func get_input_error(errors:Array):
	var all:Array
	all.resize(cell_count)
	for c in range(cell_count):
		all[c] = cells[c].get_all_error_for_input_with_errors(errors[c])
	return all

func get_total_stm_error(errors:Array):
	var all:Array
	all.resize(cell_count)
	for c in range(cell_count):
		all[c] = cells[c].get_total_error_for_stm_with_errors(errors[c])
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
