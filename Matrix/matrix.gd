extends RefCounted
class_name Matrix

var row_size:int
var col_size:int
var data:Array[PackedFloat64Array]

func _init():
	pass

func init(row:int, col:int)->Matrix:
	self.data.resize(row)
	var array:PackedFloat64Array
	array.resize(col)
	array.fill(0)
	for i in range(row):
		self.data[i] = array.duplicate()
	self.row_size = row
	self.col_size = col
	return self

static func create(data:Array[PackedFloat64Array])->Matrix:
	var this:Matrix = Matrix.new()
	var row_size:int = data.size()
	var col_size:int = data[0].size()
	
	for r in range(row_size):
		if data[r].size() != col_size:
			printerr("invalid column size!")
	
	this.row_size = row_size
	this.col_size = col_size
	this.data = data
	
	return this

func append_row(column:PackedFloat64Array)->Matrix:
	if col_size != column.size():
		printerr("invalid column size!")
	
	data.append(column)
	
	row_size += 1
	return self

func append_col(row:PackedFloat64Array)->Matrix:
	if row_size != row.size():
		printerr("invalid column size!")
	
	for r in range(row_size):
		data[r].append(row[r])
	
	col_size += 1
	return self

func fill(_data:Array[PackedFloat64Array]):
	if _data.size() == row_size:
		if _data[0].size() == col_size:
			data = _data
			return self
#	print(_data.size(), " ", row_size)
#	print(_data[0].size(), " ", col_size)
	printerr("invalid size!")

func duplicate()->Matrix:
	var result:Matrix = Matrix.new()
	
	result.data.append_array(data.duplicate(true))
	result.row_size = row_size
	result.col_size = col_size
	
	return result

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
		var row_result:PackedFloat64Array = []
		row_result.resize(result.col_size)
		var self_row:PackedFloat64Array = self.data[r]
		for c in range(result.col_size):
			var res:float = 0.0
			for i in range(self.col_size):
				res += self_row[i] * mat.data[i][c]
			row_result[c] = res
		result.data[r] = row_result
	return result

# multiplication matrix with auto transposed
func mul_t(mat:Matrix)->Matrix:
	if not self.col_size == mat.col_size:
		printerr("Cant multiply invalid shape!")
		return null
	
	var result:Matrix = Matrix.new().init(self.row_size, mat.row_size)
	
	for r in range(result.row_size):
		var row_result:PackedFloat64Array = []
		row_result.resize(result.col_size)
		var self_row:PackedFloat64Array = self.data[r]
		for c in range(result.col_size):
			var res:float = 0.0
			var mat_row:PackedFloat64Array = mat.data[c]
			for i in range(self.col_size):
				res += self_row[i] * mat_row[i]
			row_result[c] = res
		result.data[r] = row_result
	
	return result

func _mul_fast(mat:Matrix, thread_count)->Matrix:
	if not self.col_size == mat.row_size:
		printerr("Cant multiply invalid shape!")
		return null
	
	var result:Matrix = Matrix.new().init(self.row_size, mat.col_size)
	
	var threads:Array[Thread]
	threads.resize(thread_count)
	var step:float = 0.0
	var row_size:int = result.row_size
	for i in range(thread_count):
		var thread = Thread.new()
#		print(step * row_size, " ", (step + 1.0 / thread_count) * row_size)
		thread.start(
			Callable(self, "_mul").bind(self, mat, step * row_size, float(step + 1.0 / thread_count) * row_size) 
		)
		threads[i] = thread
		step += 1.0 / thread_count
	
	var return_result:Array[PackedFloat64Array]
	for i in range(thread_count):
		return_result.append_array(threads[i].wait_to_finish())
	
	result.data = return_result
#	print("this is ", return_result)
	return result

func _mul_t_fast(mat:Matrix, thread_count)->Matrix:
	if not self.col_size == mat.col_size:
		printerr("Cant multiply invalid shape!")
		return null
	
	var result:Matrix = Matrix.new().init(self.row_size, mat.row_size)
	
	var threads:Array[Thread]
	threads.resize(thread_count)
	var step:float = 0.0
	var row_size:int = result.row_size
	for i in range(thread_count):
		var thread = Thread.new()
#		print(step * row_size, " ", (step + 1.0 / thread_count) * row_size)
		thread.start(
			Callable(self, "_mul_t").bind(self, mat, step * row_size, float(step + 1.0 / thread_count) * row_size) 
		)
		threads[i] = thread
		step += 1.0 / thread_count
	
	var return_result:Array[PackedFloat64Array]
	for i in range(thread_count):
		return_result.append_array(threads[i].wait_to_finish())
	
	result.data = return_result
#	print("this is ", return_result)
	return result

static func _mul(mat1:Matrix, mat2:Matrix, from:int, to:int):
	var result:Array[PackedFloat64Array]
	result.resize(to - from)
#	print(from, to)
	for r in range(from, to):
		var row_result:PackedFloat64Array = []
		row_result.resize(mat2.col_size)
		var self_row:PackedFloat64Array = mat1.data[r]
		for c in range(mat2.col_size):
			var res:float = 0.0
			for i in range(mat1.col_size):
				res += self_row[i] * mat2.data[i][c]
			row_result[c] = res
		result[r-from] = row_result
	return result

static func _mul_t(mat1:Matrix, mat2:Matrix, from:int, to:int):
	var result:Array[PackedFloat64Array]
	result.resize(to - from)
#	print(from, to)
	for r in range(from, to):
		var row_result:PackedFloat64Array = []
		row_result.resize(mat2.row_size)
		var self_row:PackedFloat64Array = mat1.data[r]
		for c in range(mat2.row_size):
			var res:float = 0.0
			var mat_row = mat2.data[c]
			for i in range(mat1.col_size):
				res += self_row[i] * mat_row[i]
			row_result[c] = res
		result[r-from] = row_result
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

func concat_col(mat:Matrix)->Matrix:
	if row_size != mat.row_size:
		printerr("must be the same row size!")
		return
	
	var result:Matrix = self.duplicate()
	for r in range(row_size):
		result.data[r].append_array(mat.data[r].duplicate())
	result.col_size += mat.col_size
	return result

func concat_row(mat:Matrix)->Matrix:
	if col_size != mat.col_size:
		printerr("must be the same row size!")
		return
	
	var result:Matrix = self.duplicate()
	result.data.append_array(mat.data.duplicate(true))
	result.row_size += mat.row_size
	return result

func to_line()->PackedFloat64Array:
	var result:PackedFloat64Array
	
	for row in data:
		result.append_array(row)
	
	return result

func foreach_element(callable:Callable):
	var result:Array
	var size:int = get_size()
	result.resize(size)
	
	for r in range(row_size):
		for c in range(col_size):
			result[r * col_size + c] = callable.call(data[r][c])
	
	return result

func foreach_row(callable:Callable):
	var result:Array
	result.resize(row_size)
	
	for r in range(row_size):
		result[r] = callable.call(data[r])
	
	return result

func set_row_size(v):
	printerr("cannot set row size")

func set_col_size(v):
	printerr("cannot set col size")

func get_row_size()->int:
	return row_size

func get_col_size()->int:
	return col_size

func get_size()->int:
	return row_size * col_size

func is_size(row:int, col:int)->bool:
	if data.size() == row:
		for column in data:
			if column.size() != col:
				return false
		return true
	else:
		return false

static func _is_size(data:Array[PackedFloat64Array], row:int, col:int):
	if data.size() == row:
		for column in data:
			if column.size() != col:
				return false
		return true
	else:
		return false

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

func _to_dict():
	var dict:Dictionary = {
		"row" : row_size,
		"col" : col_size,
		"data" : data.duplicate(true)
	}

func load(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var dict:Dictionary = JSON.parse_string(
		file.get_as_text()
	)
	self.row_size = dict["row"]
	self.col_size = dict["col"]
	self.data = dict["data"]
	file.close()

func save(path:String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(
		JSON.stringify(_to_dict())
	)
	file.close()
