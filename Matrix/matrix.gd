extends RefCounted
## Class for Matrix Object
class_name Matrix

const E = 2.7182818284

var row_size:int
var col_size:int
var data:Array[PackedFloat64Array]

func _init():
	pass

func init(row:int, col:int, fill_value:float = 0.0)->Matrix:
	self.data.resize(row)
	var array:PackedFloat64Array
	array.resize(col)
	array.fill(fill_value)
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

static func mean(matrixs:Array[Matrix])->Matrix:
	var mat = matrixs[0]
	var matrix_count:int = matrixs.size()
	
	for i in range(1, matrix_count):
		if mat.is_equal_shape( matrixs[i] ) == false:
			printerr("Invalid size for mean!")
			return null
	
	var result:Matrix = Matrix.new().init(mat.row_size, mat.col_size)
	var row_size = mat.row_size
	var col_size = mat.col_size
	for r in range(row_size):
		var row:PackedFloat64Array = []
		row.resize(col_size)
		var matrix_row:Array[PackedFloat64Array]
		matrix_row.resize(matrix_count)
		
		for m in range(matrix_count):
			matrix_row[m] = matrixs[m].data[r]
		
		for c in range(col_size):
			var element:float = 0
			for m in range(matrix_count):
				element += matrix_row[m][c]
			row[c] = element / matrix_count
		result.data[r] = row
	
	return result

func append_row(column:PackedFloat64Array)->Matrix:
	if col_size != column.size():
		printerr("invalid column size!")
	
	var result:Matrix = self.duplicate()
	result.data.append(column)
	result.row_size += 1
	return result

func self_append_row(column:PackedFloat64Array)->Matrix:
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
	printerr("invalid size!")

func fill_force(_data:Array[PackedFloat64Array]):
	row_size = _data.size()
	col_size = _data[0].size()
	data = _data
	return self

func duplicate()->Matrix:
	var result:Matrix = Matrix.new()
	
	result.data = data.duplicate(true)
	result.row_size = row_size
	result.col_size = col_size
	
	return result

func duplicate_shufle()->Matrix:
	var result:Matrix = Matrix.new()
	
	result.data = data.duplicate(true)
	result.data.shuffle()
	
	for r in range( row_size ):
		var row = result.data[r]
		for c in range( col_size ):
			row[randi() % col_size] = randf_range(-0.9, 0.9)
	
	result.row_size = row_size
	result.col_size = col_size
	
	return result

func shufle()->Matrix:
	var random = RandomNumberGenerator.new()
	for r in range( row_size ):
		var row = data[r]
		row.fill( random.randf_range(-0.9, 0.9) )
		random.seed = randi()
		for c in range( col_size ):
			row[random.randi() % col_size] = random.randf_range(-0.9, 0.9)
	return self

func self_randomize(from:float = 10.0, to:float = 10.0)->Matrix:
	for r in range(row_size):
		var row = self.data[r]
		for c in range(col_size):
			row[c] = randf_range(from, to)
	return self

func ones():
	for i in range(row_size):
		data[i].fill(1)

func zeros():
	for i in range(row_size):
		data[i].fill(0)

func add_self(mat:Matrix)->Matrix:
	if not is_equal_shape(mat):
		printerr("false dimension of matrix!")
	for r in range(row_size):
		var my_row = self.data[r]
		var your_row = mat.data[r]
		for c in range(col_size):
			my_row[c] += your_row[c]
	return self

func min_self(mat:Matrix)->Matrix:
	if not is_equal_shape(mat):
		printerr("false dimension of matrix!")
	for r in range(row_size):
		var my_row = self.data[r]
		var your_row = mat.data[r]
		for c in range(col_size):
			my_row[c] -= your_row[c]
	return self

func add(mat:Matrix)->Matrix:
	if not is_equal_shape(mat):
		printerr("false dimension of matrix! for add")
	var result:Matrix = Matrix.new().init(row_size, col_size)
	for r in range(row_size):
		var my_row = self.data[r]
		var your_row = mat.data[r]
		var this_row:PackedFloat64Array
		this_row.resize(col_size)
		for c in range(col_size):
			this_row[c] = my_row[c] + your_row[c]
		result.data[r] = this_row
	return result

func min(mat:Matrix)->Matrix:
	if not is_equal_shape(mat):
		printerr("false dimension of matrix! for min")
	var result:Matrix = Matrix.new().init(row_size, col_size)
	for r in range(row_size):
		var my_row = self.data[r]
		var your_row = mat.data[r]
		var this_row:PackedFloat64Array
		this_row.resize(col_size)
		for c in range(col_size):
			this_row[c] = my_row[c] - your_row[c]
		result.data[r] = this_row
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

func mul2(mat:Matrix)->Matrix:
	if not is_equal_shape(mat):
		printerr("false dimension of matrix! for mul2")
		return null
	var result:Matrix = Matrix.new().init(row_size, col_size)
	for r in range(row_size):
		var my_row = self.data[r]
		var your_row = mat.data[r]
		var this_row:PackedFloat64Array
		this_row.resize(col_size)
		for c in range(col_size):
			this_row[c] = my_row[c] * your_row[c]
		result.data[r] = this_row
	return result

## multiplication matrix with auto transposed
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

func add_self_by_number(number:float)->Matrix:
	for r in range(row_size):
		for c in range(col_size):
			data[r][c] += number
	return self

func min_self_by_number(number:float)->Matrix:
	for r in range(row_size):
		for c in range(col_size):
			data[r][c] -= number
	return self

func mul_self_by_number(number:float)->Matrix:
	for r in range(row_size):
		for c in range(col_size):
			data[r][c] *= number
	return self

func div_self_by_number(number:float)->Matrix:
	for r in range(row_size):
		for c in range(col_size):
			data[r][c] /= number
	return self

func transpose()->Matrix:
	var result:Matrix = Matrix.new().init(self.col_size, self.row_size)
	
	for r in range(self.col_size):
		var arr:PackedFloat64Array = []
		arr.resize(self.row_size)
		for c in range(self.row_size):
			arr[c] = self.data[c][r]
		result.data[r] = arr
#	print(result)
	return result

func self_transpose()->Matrix:
	var result:Matrix = Matrix.new().init(self.col_size, self.row_size)
	
	for r in range(self.col_size):
		var arr:PackedFloat64Array = []
		arr.resize(self.row_size)
		for c in range(self.row_size):
			arr[c] = self.data[c][r]
		result.data[r] = arr
	self.row_size = result.row_size
	self.col_size = result.col_size
	self.data = result.data
	return self

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

func softmax()->Matrix:
	var result:Matrix = Matrix.new().init(row_size, col_size)
	var size = col_size
	var exp:PackedFloat64Array
	var numbers:PackedFloat64Array
	var total:float = 0.0
	exp.resize(size)
	for r in range(row_size):
		exp = exp.duplicate()
		numbers = data[r]
		total = 0.0
		for c in range(col_size):
			var res = pow(E, numbers[c])
			exp[c] = res
			total += res
		for c in range(col_size):
			exp[c] /= total
		result.data[r] = exp
	return result

func derivative_softmax()->Matrix:
	var result:Matrix = Matrix.new().init(row_size, col_size)
	for r in range(row_size):
		var row = result.data[r]
		var my_row = self.data[r]
		for c in range(col_size):
			var val:float = my_row[c]
			row[c] = val * (1 - val)
	return result

func self_mask_topright(value:float)->Matrix:
	for r in range(row_size):
		var row = data[r]
		for c in range(r+1, col_size):
			row[c] = value
	return self

func add_row()->Matrix:
	var result:PackedFloat64Array
	result.resize(col_size)
	
	for c in range(col_size):
		var res:float = 0.0
		for r in range(row_size):
			res += data[r][c]
		result[c] = res
	return Matrix.new().fill_force([result])

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

func self_concat_row(mat:Matrix)->Matrix:
	if col_size != mat.col_size:
		printerr("must be the same row size!")
		return
	
	data.append_array(mat.data.duplicate(true))
	row_size += mat.row_size
	return self

func sub_row(from:int, to:int)->Matrix:
	return Matrix.new().fill_force( data.slice(from, to, 1, true) )

func self_concat_row_by_array(data:Array[PackedFloat64Array])->Matrix:
	if col_size != data.size():
		printerr("must be the same row size!")
		return
	
	data.append_array(data.duplicate(true))
	row_size += data.size()
	return self

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
	return dict

func load_from_dict(_data:Dictionary):
	row_size = _data["row"]
	col_size = _data["col"]
	data.resize(row_size)
	for d in range(row_size):
		data[d] = _data["data"][d] as PackedFloat64Array
#	var __data = (_data["data"] as Array[PackedFloat64Array]).duplicate(true)
#	data = __data
	return self

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
