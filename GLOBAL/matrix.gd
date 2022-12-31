extends Reference
class_name Matrix

var data:Array
var shape:Array

func _init(_shape = null) -> void:
	if typeof(_shape) == TYPE_ARRAY:
		self.shape = _shape
		data.resize(_shape[0])
		var row_len = _shape[1]
		for i in range(_shape[0]):
			var row = []
			row.resize(row_len)
			row.fill(0)
			data[i] = row
	elif typeof(_shape) == TYPE_NIL:
		return

func add(matrix:Matrix) -> Matrix:
	if self.shape == matrix.shape:
		for j in range(self.shape[0]):
			for i in range(self.shape[1]):
				self.data[j][i] += matrix.data[j][i]
	else:
		printerr("Invalid matrix size!")
	return self
	
func sub(matrix:Matrix) -> Matrix:
	if self.shape == matrix.shape:
		for j in range(self.shape[0]):
			for i in range(self.shape[1]):
				self.data[j][i] -= matrix.data[j][i]
	else:
		printerr("Invalid matrix size!")
	return self

func fill(array:Array) -> void:
#	if array.size() < (shape[0] * shape[1]):
	
	var row_len = shape[1]
	for j in range(shape[0]):
		for i in range(shape[1]):
			data[j][i] = array[j * row_len + i]
	
	
func _to_string() -> String:
	var string = "[\n"
	for i in range(shape[0]):
		string += str(i) + "\t" + str(data[i]) + "\n"
	string += "]"
	return string
