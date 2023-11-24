@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var matrix:Matrix = Matrix.new().fill_force(
		[
			[1, 2, 3],
			[3, 1, 2],
			[2, 3, 1],
		]
	)
	var matrix2:Matrix = Matrix.new().init(3, 3).init_random_value(-1.0, 1.0)
#	print(matrix.inverse().mul(matrix))
	print(matrix2)
	print(matrix2.mul(matrix).mul(matrix.inverse()))
	return
#	print(matrix.determinan())
#	return
	
	var result_p:Array
	var result_m:Array
	
	var len = 3
	var total_element = pow(len - 1, 2)
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
#			for i in range(y, 0, -1):
#				element.append(i)
#			for i in range(y, len, 1):
#				element.append(i)
			var _t = element_x.duplicate(true)
			_t.reverse()
			result_p.append([element_y, element_x])
			result_m.append([element_y, _t])
#			print([y, x], " ", matrix.data[y][x])
	
	var new_m:Matrix = Matrix.new().init(len, len)
	
	for y in range(len):
		for x in range(len):
			var value:float
			var pos:float = 1
			var min:float = -1
			for i in range(len-1):
				var index = y * len + x
				pos *= matrix.data[result_p[index][0][i]][result_p[index][1][i]]
				min *= matrix.data[result_m[index][0][i]][result_m[index][1][i]]
			
			new_m.data[y][x] = (pos + min) * (1 - 2 * ((x+y)%2))
	
	print(new_m)
#	print(result_p)
