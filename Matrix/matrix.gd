extends RefCounted
## Class for Matrix Object
class_name Matrix

const EULER = 2.7182818284

var row_size:int
var col_size:int
var data:Array[PackedFloat64Array]

func _init():
	pass

func init(row:int, col:int, fill_value:float = 0.0)->Matrix:
	self.row_size = row
	self.col_size = col
	self.data.resize(row)
	if col == 0:
		return self
	var array:PackedFloat64Array
	array.resize(col)
	array.fill(fill_value)
	for i in range(row):
		self.data[i] = array.duplicate()
	return self

func init_random_value(from:float, to:float)->Matrix:
	for r in range(row_size):
		var row:PackedFloat64Array = data[r]
		for c in range(col_size):
			row[c] = randf_range(from, to)
	return self

func init_box_muller(mean:float = 0.3, deviation:float = 0.1)->Matrix:
	for r in range(row_size):
		var row:PackedFloat64Array = data[r]
		for c in range(col_size):
			row[c] = randfn(mean, deviation)
	return self

func init_diagonal(value:float = 1.0):
	if not is_square():
		printerr("Invalid init diagonal for non square matrix! ", row_size, "x", col_size)
		return null
	
	for r in range(row_size):
		data[r][r] = 1.0
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
	
#	for i in range(1, matrix_count):
#		if mat.is_equal_shape( matrixs[i] ) == false:
#			printerr("Invalid size for mean!")
#			return null
	
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

func self_resquare_diagonal(value:float = 1.0)->Matrix:
	var original:PackedFloat64Array
	original.resize(col_size)
	original.fill(0.0)
	for i in range(row_size, col_size):
		var array = original.duplicate()
		array[i] = value
		data.append(array)
	row_size = col_size
	return self

func self_pop_row(count:int = 1):
	if count > row_size:
		printerr("pop to many element in pop row!")
		return
	row_size -= count
	data = data.slice(0, row_size)

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

func self_append_rows(columns:Array[PackedFloat64Array])->Matrix:
	if col_size != columns[0].size():
		printerr("invalid column size!")
	
	data.append_array(columns)
	
	row_size += columns.size()
	return self

func append_col(row:PackedFloat64Array)->Matrix:
	if row_size != row.size():
		printerr("invalid column size!")
	
	for r in range(row_size):
		data[r].append(row[r])
	
	col_size += 1
	return self

func at_row(row_index:int):
	if row_index >= row_size:
		printerr("Out of index ", row_index, " while the row size was ", row_size)
		return
	return Matrix.new().init(1, col_size).fill_rows(data[row_index])

func self_assign(_data:Array[PackedFloat64Array]):
	if _data.size() > row_size:
		printerr("invalid row size in self assign!")
		return null
	if _data[0].size() != col_size:
		printerr("invalid col size in self assign")
		return null
	
	if _data.size() == row_size:
		data = _data
	else:
		_data.append_array(
			data.slice(
				_data.size(), row_size
			)
		)
		data = _data
	return self

func self_assign_m(matrix:Matrix):
	if matrix.row_size > row_size:
		printerr("invalid row size in self assign matrix!")
		return null
	if matrix.col_size != col_size:
		printerr("invalid col size in self assign matrix!")
		return null
	
	if matrix.row_size == row_size:
		data = matrix.data.duplicate(true)
	else:
		var data = matrix.data.duplicate(true)
		data.append_array(
			self.data.slice(
				matrix.row_size, row_size
			)
		)
		self.data = data
	return self

func fill(_data:Array[PackedFloat64Array]):
	if _data.size() == row_size:
		if _data[0].size() == col_size:
			data = _data
			return self
	printerr("invalid size!")

func fill_force(_data:Array[PackedFloat64Array])->Matrix:
	row_size = _data.size()
	col_size = _data[0].size()
	data = _data
	return self

func fill_rows(row:PackedFloat64Array):
	if col_size != row.size():
		printerr("Invalid col size for fill rows!")
		return null
	
	for r in range(row_size):
		data[r] = row.duplicate()
	return self

func fill_cols(col:PackedFloat64Array):
	if row_size != col.size():
		printerr("Invalid col size for fill rows!")
		return null
	
	for r in range(row_size):
		data[r].fill(col[r])
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

func self_randomize(from:float = -10.0, to:float = 10.0)->Matrix:
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

func add_singlerow_to_all(singlerow:Matrix)->Matrix:
	if singlerow.row_size != 1:
		printerr("not single row!")
		return null
	if singlerow.col_size != self.col_size:
		printerr("cant add invalid shape in add_singlerow_to_all!")
		return null
	
	var result:Matrix = self.duplicate()
	var single_row:PackedFloat64Array = singlerow.data[0]
	for r in range(row_size):
		var result_row:PackedFloat64Array = result.data[r]
		for c in range(col_size):
			result_row[c] += single_row[c]
	
	return result

func self_add_singlerow_to_all(singlerow:Matrix)->Matrix:
	if singlerow.row_size != 1:
		printerr("not single row!")
		return null
	if singlerow.col_size != self.col_size:
		printerr("cant add invalid shape in self_add_singlerow_to_all!")
		print()
		return null
	
	var single_row:PackedFloat64Array = singlerow.data[0]
	for r in range(row_size):
		var my_row:PackedFloat64Array = self.data[r]
		for c in range(col_size):
			my_row[c] += single_row[c]
	
	return self

func self_add_row(at:int, numbers:PackedFloat64Array):
	var size:int = numbers.size()
	if self.col_size != size:
		printerr("false colomn size for self_add_row")
		return null
	if self.row_size < at:
		printerr("false row index for self_add_row")
		return null
#	print(self.row_size, " ", at)
	var row:PackedFloat64Array = self.data[at]
	for c in range(size):
		row[c] += numbers[c]
	
	return self

func self_min_row(at:int, numbers:PackedFloat64Array):
	var size:int = numbers.size()
	if self.col_size != size:
		printerr("false colomn size for self_min_row")
		return null
	if self.row_size < at:
		printerr("false row index for self_min_row")
		print("max row ", self.row_size, " given ", at)
		return null
	
	var row:PackedFloat64Array = self.data[at]
	for c in range(size):
		row[c] -= numbers[c]
	
	return self

func add_self(mat:Matrix)->Matrix:
	if not is_equal_shape(mat):
		printerr("false dimension of matrix!")
		return null
	for r in range(row_size):
		var my_row = self.data[r]
		var your_row = mat.data[r]
		for c in range(col_size):
			my_row[c] += your_row[c]
	return self

func min_self(mat:Matrix)->Matrix:
	if not is_equal_shape(mat):
		printerr("false dimension of matrix for min self!")
		print("This shape is ", get_shape(), " but given ", mat.get_shape())
		return null
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
#	print("my shape ", get_shape())
	if not is_equal_shape(mat):
		printerr("false dimension of matrix for min!")
		return null
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
		print("matrix ", self.row_size, "x", self.col_size, " for matrix ", mat.row_size, "x", mat.col_size)
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
		print("matrix ", self.row_size, "x", self.col_size, " for matrix transpose", mat.col_size, "x", mat.row_size)
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

func _mul_fast(mat:Matrix, thread_count:int = 2)->Matrix:
	if not self.col_size == mat.row_size:
		printerr("Cant multiply invalid shape!")
		print("matrix ", self.row_size, "x", self.col_size, " for matrix ", mat.row_size, "x", mat.col_size)
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
		print("matrix ", self.row_size, "x", self.col_size, " for matrix transpose", mat.col_size, "x", mat.row_size)
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

static func multi_to_dict(matrices:Array[Matrix])->Array:
	var result:Array
	result.resize(matrices.size())
	
	for i in range(matrices.size()):
		result[i] = matrices[i].to_dict()
	
	return result

static func multi_mul(matrices1:Array[Matrix], matrices2:Array[Matrix])->Array[Matrix]:
	if matrices1.size() != matrices2.size():
		printerr("unequal size of matrices in multi mul")
		return []
	var matrices_size:int = matrices1.size()
	var matrices_result:Array[Matrix]
	matrices_result.resize(matrices_size)
	
	for i in range(matrices_size):
		matrices_result[i] = matrices1[i].mul(matrices2[i])
	
	return matrices_result

static func multi_mul_t(matrices1:Array[Matrix], matrices2:Array[Matrix])->Array[Matrix]:
	if matrices1.size() != matrices2.size():
		printerr("unequal size of matrices in multi mul")
		return []
	var matrices_size:int = matrices1.size()
	var matrices_result:Array[Matrix]
	matrices_result.resize(matrices_size)
	
	for i in range(matrices_size):
		matrices_result[i] = matrices1[i].mul_t(matrices2[i])
	
	return matrices_result

static func multi_div_by_number(matrices:Array[Matrix], number:float)->Array[Matrix]:
	for matrix in matrices:
#		print("before scale down ", matrix)
		matrix.div_self_by_number(number)
#		print("after scale down ", matrix)
	return matrices

static func multi_softmax(matrices:Array[Matrix])->Array[Matrix]:
	var new_matrices:Array[Matrix]
	new_matrices.resize(matrices.size())
	for i in range(matrices.size()):
		new_matrices[i] = matrices[i]._safe_softmax()
	return new_matrices

static func multi_reverse_row(matrices:Array[Matrix])->Array[Matrix]:
	for matrix in matrices:
		matrix.self_reverse_row()
	return matrices

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

func min_self_selected_row(numbers:PackedFloat64Array, at:int)->Matrix:
	if numbers.size() != col_size:
		printerr("Invalid col size for add_self_selected_row!")
		return null
	if at > row_size:
		printerr("Invalid row index for add_self_selected_row!")
		return null
	var row = data[at]
	for c in range(col_size):
		row[c] += numbers[c]
	return self

func min_self_selected_col(numbers:PackedFloat64Array, at:int)->Matrix:
	if numbers.size() != row_size:
		printerr("Invalid row size for add_self_selected_row!")
		return null
	if at > col_size:
		printerr("Invalid col index for add_self_selected_row!")
		return null
	for r in range(row_size):
		data[r][at] += numbers[r]
	return self

func add_on_all()->float:
	var result:float = 0.0
	for r in range(row_size):
		var row:PackedFloat64Array = data[r]
		for c in range(col_size):
			result += row[c]
	return result

func add_on_row()->PackedFloat64Array:
	var result:PackedFloat64Array = []
	result.resize(row_size)
	for r in range(row_size):
		var row:PackedFloat64Array = data[r]
		var thisresult:float = 0.0
		for c in range(col_size):
			thisresult += row[c]
		result[r] = thisresult
	return result

func add_on_col()->PackedFloat64Array:
	var result:PackedFloat64Array = []
	result.resize(col_size)
	for r in range(row_size):
		var row:PackedFloat64Array = data[r]
		for c in range(col_size):
			result[c] += row[c]
	return result

static func this_row_add_with_row(row1:PackedFloat64Array, row2:PackedFloat64Array, from:int = 0):
	if row1.size() != row2.size():
		printerr("Invalid size for this_row_add_with_row!")
		return []
	
	for i in range(from, row1.size()):
		row1[i] += row2[i]
	return row1

static func this_row_min_with_row(row1:PackedFloat64Array, row2:PackedFloat64Array, from:int = 0):
	if row1.size() != row2.size():
		printerr("Invalid size for this_row_min_with_row!")
		return []
	
	for i in range(from, row1.size()):
		row1[i] -= row2[i]
	return row1

static func this_row_mul_with_number(row:PackedFloat64Array, number:float, from:int = 0):
	for i in range(from, row.size()):
		row[i] *= number
	return row

static func this_row_div_with_number(row:PackedFloat64Array, number:float, from:int = 0):
	for i in range(from, row.size()):
		row[i] /= number
	return row

func self_reverse_row()->Matrix:
	self.data.reverse()
	return self

func transpose()->Matrix:
	var result:Matrix = Matrix.new().init(self.col_size, self.row_size)
	for r in range(self.col_size):
		var arr:PackedFloat64Array = []
		arr.resize(self.row_size)
		for c in range(self.row_size):
			arr[c] = self.data[c][r]
		result.data[r] = arr
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

func determinan()->float:
	if not is_square():
		printerr("cannot find determinan on non-square matrix!")
		return -INF
	
	var length = col_size
	var right:float = 0.0
	var left:float = 0.0
	
	if length == 2:
		right = data[0][0] * data[1][1]
		left = data[0][1] * data[1][0]
	else:
		for k in range(length):
			right = 0.0
			left = 0.0
			for j in range(length):
				var v:float = 1.0
				for i in range(length):
					v *= data[i][(i+j+k) % length]
				right += v
				
			
			for j in range(length-1, -1, -1):
				var v:float = 1.0
				for i in range(length):
					v *= data[i][(j-i+k) % length]
				print(v)
				left += v
	
	return right - left

func determinan2():
	if not is_square():
		printerr("cannot find determinan on non-square matrix!")
		return -INF
	
	var length:int = col_size
	
	var result_p:Array
	var result_m:Array
	
	var len = col_size
	for y in range(len):
		for x in range(len):
			var pos_x:int = x
			var pos_y:int = y
			var element_y:Array
			var element_x:Array
			
			element_y.append_array(
				range(0, y)
			)
			element_y.append_array(
				range(y+1, len)
			)
			element_x.append_array(
				range(0, x)
			)
			element_x.append_array(
				range(x+1, len)
			)
			if x == 0 and y == 0:
				print([element_y, element_x])
			var _t = element_x.duplicate(true)
			_t.reverse()
			result_p.append([element_y, element_x])
			result_m.append([element_y, _t])
	return 

func adjoint()->Matrix:
	if not is_square():
		printerr("Cant make adjoint on not square ", row_size, "x", col_size)
		return null
	
	var result:Matrix = Matrix.new().init(row_size, col_size)
	var result_p:Array
	var result_m:Array
	
	var len = col_size
	for y in range(len):
		for x in range(len):
			var pos_x:int = x
			var pos_y:int = y
			var element_y:Array
			var element_x:Array
			
			element_y.append_array(
				range(0, y)
			)
			element_y.append_array(
				range(y+1, len)
			)
			element_x.append_array(
				range(0, x)
			)
			element_x.append_array(
				range(x+1, len)
			)
			if x == 0 and y == 0:
				print([element_y, element_x])
			var _t = element_x.duplicate(true)
			_t.reverse()
			result_p.append([element_y, element_x])
			result_m.append([element_y, _t])
	
	for y in range(len):
		for x in range(len):
			var index = y * len + x
			var result_p_index_0 = result_p[index][0]
			var result_m_index_0 = result_m[index][0]
			var result_p_index_1 = result_p[index][1]
			var result_m_index_1 = result_m[index][1]
			var value:float
			if len > 2:
				value = 0.0
				for j in range(len-1):
					var pos:float = 1
					var min:float = -1
					for i in range(len-1):
						var my_index:int = (i+j)%(len-1)
						pos *= data[result_p_index_0[i]][result_p_index_1[my_index]]
						min *= data[result_m_index_0[i]][result_m_index_1[my_index]]
					value += pos+min
#				result.data[y][x] = value * (1 - 2 * ((x+y)%2))
			else:
				var pos:float = 1
				var min:float = -1
				for i in range(len-1):
					pos *= data[result_p_index_0[i]][result_p_index_1[i]]
					min *= data[result_m_index_0[i]][result_m_index_1[i]]
				value = pos + min
			result.data[y][x] = value * (1 - 2 * ((x+y)%2))
	return result

func _inverse()->Matrix:
	var result:Matrix
	var determinant:float = determinan()
	var adjoint = adjoint()
	
	result = adjoint.transpose().div_self_by_number(determinan())
	
	return result

#Gauss-Jordan Elimination
func inverse()->Matrix:
	var result:Matrix = Matrix.new().init(row_size, col_size).init_diagonal(1.0)
	var usedmatrix:Matrix = self.duplicate()
	var usedmatrixdata = usedmatrix.data
	var resultdata = result.data
	var number
	for r in range(row_size):
		number = usedmatrixdata[r][r]
		this_row_div_with_number(resultdata[r], number)
		this_row_div_with_number(usedmatrixdata[r], number)
		for i in range(r+1, row_size):
			number = usedmatrixdata[i][r]
			this_row_min_with_row(
				resultdata[i], 
				this_row_mul_with_number(
					resultdata[r].duplicate(), number
				)
			)
			this_row_min_with_row(
				usedmatrixdata[i], 
				this_row_mul_with_number(
					usedmatrixdata[r].duplicate(), number
				)
			)
#	print(result)
	for r in range(row_size):
		for i in range(r):
			number = usedmatrixdata[i][r]
			this_row_min_with_row(
				resultdata[i], 
				this_row_mul_with_number(
					resultdata[r].duplicate(), number
				)
			)
			this_row_min_with_row(
				usedmatrixdata[i], 
				this_row_mul_with_number(
					usedmatrixdata[r].duplicate(), number
				)
			)
			print(usedmatrix)
			print(result, "\n")
	
	return result

func inverse_custom(skip:int)->Matrix:
	var result:Matrix = Matrix.new().init(row_size, col_size).init_diagonal(1.0)
	var usedmatrix:Matrix = self.duplicate()
	var usedmatrixdata = usedmatrix.data
	var resultdata = result.data
	var number
	for r in range(row_size):
		number = usedmatrixdata[r][r]
		this_row_div_with_number(resultdata[r], number)
		this_row_div_with_number(usedmatrixdata[r], number)
		for i in range(r+1, skip):
			number = usedmatrixdata[i][r]
			this_row_min_with_row(
				resultdata[i], 
				this_row_mul_with_number(
					resultdata[r].duplicate(), number
				)
			)
			this_row_min_with_row(
				usedmatrixdata[i], 
				this_row_mul_with_number(
					usedmatrixdata[r].duplicate(), number
				)
			)
#	print(usedmatrix)
#	print(result)
	for r in range(row_size):
		for i in range(r, skip):
			number = usedmatrixdata[i][r]
			this_row_min_with_row(
				resultdata[i], 
				this_row_mul_with_number(
					resultdata[r].duplicate(), number
				)
			)
			this_row_min_with_row(
				usedmatrixdata[i], 
				this_row_mul_with_number(
					usedmatrixdata[r].duplicate(), number
				)
			)
#	print(usedmatrix)
	return result

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
			var res = pow(EULER, numbers[c])
			exp[c] = res
			total += res
		for c in range(col_size):
			exp[c] /= total
		result.data[r] = exp
	return result

func _safe_softmax()->Matrix:
	var result:Matrix = Matrix.new().init(row_size, col_size)
	var size = col_size
	var exp:PackedFloat64Array
	var numbers:PackedFloat64Array
	var total:float = 0.0
	exp.resize(size)
	
	var is_safe_from_nan:bool = true
	var is_safe_from_inf:bool = true
	
	for r in range(row_size):
		exp = exp.duplicate()
		numbers = data[r]
		total = 0.0
		for c in range(col_size):
			var res = pow(EULER, numbers[c])
			if is_safe_from_inf:
				if is_inf(res):
					printerr("inf because pow(", EULER, ", ", numbers[c], ")")
					is_safe_from_inf = false
			exp[c] = res
			total += res
		for c in range(col_size):
			if is_safe_from_nan:
				if is_nan(exp[c]/total):
					printerr("nan because ", exp[c], "/", total)
					is_safe_from_nan = false
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

func row_mean()->PackedFloat64Array:
	var col_size:int = self.col_size
	var result:PackedFloat64Array
	result.resize(row_size)
	for r in range(row_size):
		var row = data[r]
		var mean:float = 0.0
		for num in row:
			mean += num
		result[r] = mean/col_size
#		print(result)
	return result

func row_deviation(means = null)->PackedFloat64Array:
	var col_size:int = self.col_size
	if means == null:
		means = row_mean()
#	print(means)
	var result:PackedFloat64Array
	result.resize(row_size)
	for r in range(row_size):
		var row = data[r]
		var mean:float = means[r]
		var deviation:float = 0.0
#		print(col_size)
		for c in range(col_size):
			deviation += pow( (mean-row[c]) , 2)
#			print(deviation)
		result[r] = sqrt( deviation/col_size )
	return result

func batch_normalization(weight:float, bias:float)->Matrix:
	var normalized:Matrix = Matrix.new().init(row_size, col_size)
	for r in range(row_size):
		var normalized_row = normalized.data[r]
		var my_row = data[r]
		for c in range(col_size):
			normalized_row[c] = my_row[c] * weight + bias
	return normalized

func self_activation_normalization()->Matrix:
	var means = row_mean()
	var denominators = row_deviation(means)
	var result
	for r in range(row_size):
		var mean:float = means[r]
		var denominator:float = denominators[r]
		var my_row = data[r]
		for c in range(col_size):
			my_row[c] = (my_row[c] - mean) / denominator
	return self

func minmax_normalization()->Matrix:
	var result:Matrix = Matrix.new().init(row_size, col_size)
	for r in range(row_size):
		var row:PackedFloat64Array = data[r]
		var max:float = 0.0
		var min:float = 0.0
		for i in range(col_size):
			var this:float = row[i]
			if this > max:
				max = this
			if min > this:
				min = this
		var your_row:PackedFloat64Array = result.data[r]
		var denominator:float = max - min
		for c in range(col_size):
			your_row[c] = (row[c] - min)/denominator
	return result

func self_minmax_normalization()->Matrix:
	for r in range(row_size):
		var row:PackedFloat64Array = data[r]
		var max:float = 0.0
		var min:float = 0.0
		for i in range(col_size):
			var this:float = row[i]
			if this > max:
				max = this
			if min > this:
				min = this
		var denominator:float = max - min
		for c in range(col_size):
			row[c] = (row[c] - min)/denominator
	return self

func self_minmax_normalization_range(from:float, to:float)->Matrix:
	var range:float = to-from
	for r in range(row_size):
		var row:PackedFloat64Array = data[r]
		var max:float = 0.0
		var min:float = 0.0
		for i in range(col_size):
			var this:float = row[i]
			if this > max:
				max = this
			if min > this:
				min = this
		var denominator:float = max - min
		for c in range(col_size):
			row[c] = from + ((row[c] - min)*(range))/denominator
	return self

func activation_normalization()->Matrix:
	var normalized:Matrix = Matrix.new().init(row_size, col_size)
	var means = row_mean()
	var denominators = row_deviation(means)
	var result
	for r in range(row_size):
		var mean:float = means[r]
		var denominator:float = denominators[r]
		var normalized_row = normalized.data[r]
		var my_row = data[r]
		for c in range(col_size):
			normalized_row[c] = (my_row[c] - mean) / denominator
	return normalized

func activation_tanh()->Matrix:
	var new_matrix:Matrix = Matrix.new().init(row_size, col_size)
	for r in range(row_size):
		var my_row = data[r]
		var new_row = new_matrix.data[r]
		for c in range(col_size):
			new_row[c] = tanh(my_row[c])
	return new_matrix

func activation_sigmoid()->Matrix:
	var new_matrix:Matrix = Matrix.new().init(row_size, col_size)
	for r in range(row_size):
		var my_row = data[r]
		var new_row = new_matrix.data[r]
		for c in range(col_size):
			new_row[c] = 1.0/(1.0 + pow(EULER, -my_row))
	return new_matrix

func activation_softmax()->Matrix:
	return self.softmax()

func self_mask_topright(value:float)->Matrix:
	for r in range(row_size):
		var row = data[r]
		for c in range(r+1, col_size):
			row[c] = value
	return self

func slice_row(from:int, to:int)->Matrix:
	var new_row_size:int = to - from
	var new_matrix:Matrix = Matrix.new().init(new_row_size, col_size)
	
	new_matrix.data = data.slice(from, to)
	
	return new_matrix

func split_col(count:int)->Array[Matrix]:
	if (col_size % count) != 0:
		printerr("Unbalanced split col for ", col_size, "/", count)
		return []
	var matrices:Array[Matrix]
	matrices.resize(count)
	var col_length:int = col_size / count
	for mat in range(count):
		var matrix:Matrix = Matrix.new().init(row_size, col_length)
		var matrix_data = matrix.data
		for r in range(row_size):
			matrix_data[r] = data[r].slice(mat*col_length, (mat+1)*col_length)
		matrices[mat] = matrix
	return matrices

static func join_col(matrices:Array[Matrix])->Matrix:
	if matrices.is_empty():
		printerr("Empty matrices on join col")
		return null
	var joined_matrix:Matrix = Matrix.new()
	var count:int = matrices.size()
	var row_size = matrices[0].row_size
	var col_size = matrices[0].col_size
	var data:Array[PackedFloat64Array] = matrices[0].data
	
	for r in range(row_size):
		for i in range(1, count):
			data[r].append_array(matrices[i].data[r])
	joined_matrix.row_size = row_size
	joined_matrix.col_size = col_size * count
	joined_matrix.data = data
	
	return joined_matrix

static func row_addition(row1:PackedFloat64Array, row2:PackedFloat64Array)->PackedFloat64Array:
	if row1.size() != row2.size():
		printerr("Invalid row size for row addition!")
		return []
	var row_result:PackedFloat64Array
	row_result.resize(row1.size())
	
	for i in range(row1.size()):
		row_result[i] = row1[i] + row2[i]
	
	return row_result

static func row_minus(row1:PackedFloat64Array, row2:PackedFloat64Array)->PackedFloat64Array:
	if row1.size() != row2.size():
		printerr("Invalid row size for row minus!")
		return []
	var row_result:PackedFloat64Array
	row_result.resize(row1.size())
	
	for i in range(row1.size()):
		row_result[i] = row1[i] - row2[i]
	
	return row_result

static func row_multiply(row1:PackedFloat64Array, row2:PackedFloat64Array)->PackedFloat64Array:
	if row1.size() != row2.size():
		printerr("Invalid row size for row multiply!")
		return []
	var row_result:PackedFloat64Array
	row_result.resize(row1.size())
	
	for i in range(row1.size()):
		row_result[i] = row1[i] * row2[i]
	
	return row_result

static func row_devision(row1:PackedFloat64Array, row2:PackedFloat64Array)->PackedFloat64Array:
	if row1.size() != row2.size():
		printerr("Invalid row size for row devision!")
		return []
	var row_result:PackedFloat64Array
	row_result.resize(row1.size())
	
	for i in range(row1.size()):
		row_result[i] = row1[i] / row2[i]
	
	return row_result

static func self_row_multiply_by_number(row:PackedFloat64Array, number:float)->PackedFloat64Array:
	for i in range(row.size()):
		row[i] = row[i] * number
	return row

func row_add()->Matrix:
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
		printerr("must be the same row size for concat col!")
		printerr("expected ", row_size, " but given ", mat.row_size)
		return
	
	var result:Matrix = self.duplicate()
	for r in range(row_size):
		result.data[r].append_array(mat.data[r])
	result.col_size += mat.col_size
	return result

func concat_row(mat:Matrix)->Matrix:
	if col_size != mat.col_size:
		printerr("must be the same col size for concat row!")
		printerr("expected ", col_size, " but given ", mat.col_size)
		return
	
	var result:Matrix = self.duplicate()
	result.data.append_array(mat.data.duplicate(true))
	result.row_size += mat.row_size
	return result

func self_concat_col(mat:Matrix)->Matrix:
	if row_size != mat.row_size:
		printerr("must be the same col size for self concat col!")
		return
	
	for r in range(row_size):
		data[r].append_array(mat.data[r])
	col_size += mat.col_size
	return self

func self_concat_row(mat:Matrix)->Matrix:
	if col_size != mat.col_size:
		printerr("must be the same col size for self concat row!")
		return
	
	data.append_array(mat.data.duplicate(true))
	row_size += mat.row_size
	return self

func sub_row(from:int, to:int)->Matrix:
	return Matrix.new().fill_force( data.slice(from, to, 1, true) )

#func 

func self_concat_row_by_array(data:Array[PackedFloat64Array])->Matrix:
	if col_size != data.size():
		printerr("must be the same row size for self concat row by array!")
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

func get_row(at:int)->PackedFloat64Array:
	return data[at].duplicate()

func get_col(at:int)->PackedFloat64Array:
	var result:PackedFloat64Array
	result.resize(row_size)
	for r in range(row_size):
		result[r] = data[r][at]
	return result

func get_total_element()->int:
	return row_size * col_size

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

func get_shape()->PackedInt64Array:
	return [row_size, col_size]

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
	if self.row_size == mat.row_size:
		if self.col_size == mat.col_size:
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
#	var s:String
#	for  i in range(row_size):
#		s += str(data[i]) + "\n"
#	return s
	return str(_to_dict())

func _to_dict():
	var dict:Dictionary = {
		"row" : row_size,
		"col" : col_size,
		"data" : data.duplicate(true)
	}
	return dict

func to_dict():
	return _to_dict()

static func init_from_dict(_data:Dictionary)->Matrix:
	var this_matrix:Matrix = Matrix.new()
	this_matrix.row_size = _data["row"]
	this_matrix.col_size = _data["col"]
	this_matrix.data.resize(this_matrix.row_size)
	var source_data = _data["data"]
	var this_data = this_matrix.data
	for d in range(this_matrix.row_size):
		this_data[d] = source_data[d] as PackedFloat64Array
	return this_matrix

func load_from_dict(_data:Dictionary):
	row_size = _data["row"]
	col_size = _data["col"]
	data.resize(row_size)
	for d in range(row_size):
		data[d] = _data["data"][d] as PackedFloat64Array
#	var __data = (_data["data"] as Array[PackedFloat64Array]).duplicate(true)
#	data = __data
	return self

func load_from_string(_data_s:String):
	var _data = JSON.parse_string(_data_s)
	return load_from_dict(_data)

func load(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var dict:Dictionary = JSON.parse_string(
		file.get_as_text()
	)
	load_from_dict(dict)
	file.close()

func save(path:String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(
		JSON.stringify(_to_dict(), "\t", false, true)
	)
	file.close()
