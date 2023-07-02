extends RefCounted
class_name Matrix

var data:Array[PackedFloat64Array]
var row_size:int
var col_size:int

func _init():
	pass

func init(row:int, col:int):
	self.data.resize(row)
	var array:PackedFloat64Array
	array.resize(col)
	array.fill(0)
	for i in range(row):
		self.data[i] = array.duplicate()
	row_size = row
	col_size = col
	return self

func fill(_data:Array[PackedFloat64Array]):
	if _data.size() == row_size:
		if _data[0].size() == col_size:
			data = _data
			return
#	print(_data.size(), " ", row_size)
#	print(_data[0].size(), " ", col_size)
	printerr("invalid size!")

func ones():
	for i in range(row_size):
		data[i].fill(1)

func zeros():
	for i in range(row_size):
		data[i].fill(0)

func add(mat:Matrix)->Matrix:
	if not is_equal_shape(mat):
		printerr("false dimension of matrix!")
	var result:Matrix = Matrix.new()
	for r in range(row_size):
		var my_row = self.data[r]
		var your_row = mat.data[r]
		var this_row:PackedFloat64Array
		this_row.resize(row_size)
		for c in range(col_size):
			this_row[c] = my_row[c] + your_row[c]
		result.add_row(this_row)
	return result

func min(mat:Matrix)->Matrix:
	if not is_equal_shape(mat):
		printerr("false dimension of matrix!")
	var result:Matrix = Matrix.new()
	for r in range(row_size):
		var my_row = self.data[r]
		var your_row = mat.data[r]
		var this_row:PackedFloat64Array
		this_row.resize(row_size)
		for c in range(col_size):
			this_row[c] = my_row[c] - your_row[c]
		result.add_row(this_row)
	return result

func mul(mat:Matrix)->Matrix:
	if not self.col_size == mat.row_size:
		printerr("Cant multiply invalid shape!")
		return null
	
	var result:Matrix = Matrix.new().init(self.row_size, mat.col_size)
	
	for r in range(result.row_size):
		for c in range(result.col_size):
			var res:float = 0.0
			for i in range(self.col_size):
				res += self.data[r][i] * mat.data[i][c]
			result.data[r][c] = res
	return result

func add_by_number(number:float)->void:
	for r in range(row_size):
		for c in range(col_size):
			data[r][c] += number

func min_by_number(number:float)->void:
	for r in range(row_size):
		for c in range(col_size):
			data[r][c] -= number

func mul_by_number(number:float)->void:
	for r in range(row_size):
		for c in range(col_size):
			data[r][c] *= number

func div_by_number(number:float)->void:
	for r in range(row_size):
		for c in range(col_size):
			data[r][c] /= number

func transpose()->Matrix:
	var result:Matrix = Matrix.new().init(self.col_size, self.row_size)
	
	for r in range(self.col_size):
		var arr:PackedFloat64Array = []
		arr.resize(self.row_size)
		for c in range(self.row_size):
			arr[c] = self.data[c][r]
		result.data[r] = arr
	return result

func determinan():
	if not is_square():
		printerr("cannot find determinan on non-square matrix!")
		return null
	
	var length = col_size
	var right:float = 0.0
	var left:float = 0.0
	
	if length == 2:
		right = data[0][0] * data[1][1]
		left = data[0][1] * data[1][0]
	else:
		for j in range(length):
			var v:float = 1.0
			for i in range(length):
				v *= data[i][(i+j) % length]
				print((i+j) % length)
			right += v
			print(v)
		
		for j in range(length-1, -1, -1):
			var v:float = 1.0
			for i in range(length):
				v *= data[i][(j-i) % length]
			left += v
			print(v)
	
	return right - left

func add_row(column:PackedFloat64Array):
	data.append(column)
	row_size += 1

func set_row_size(v):
	printerr("cannot set row size")

func set_col_size(v):
	printerr("cannot set col size")

func get_row_size()->int:
	return row_size

func get_col_size()->int:
	return col_size

func is_equal_shape(mat:Matrix)->bool:
	if self.get_row_size() == mat.get_row_size():
		if self.get_col_size() == mat.get_col_size():
			return true
		return false
	else:
		return false

func is_square()->bool:
	if row_size == col_size:
		return true
	else:
		return false

func _to_string():
	var s:String
	for  i in range(row_size):
		s += str(data[i]) + "\n"
	return s
