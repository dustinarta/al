@tool
extends Node

const E = 2.7182818284

class Table:
	var column_name:PackedStringArray
	var column_type:Array[DataType]
	var column_can_empty:Array[bool]
	var column_is_primary:Array[bool]
	
	var rows:Array[Array]
	
	enum DataType {
		string,
		number,
		bool,
		datetime
	}
	
	func _init(names:PackedStringArray, types:PackedStringArray):
		var size:int
		if names.size() != types.size():
			printerr("expected more argument")
			return
		size = names.size()
		for i in range(size):
			column_name.append(names[i])
			if not DataType.has(types[i]):
				printerr("undefined data type ", types)
				return
			column_type.append(DataType[types[i]])
	
	func insert(columns:PackedStringArray, values:Array):
		var size:int
		if columns.size() != values.size():
			printerr("expected more argument")
			return
		size = columns.size()
		var elemen:Array
		elemen.resize(size)
		for i in range(size):
			var at = column_name.find(columns[i])
			if at == -1:
				printerr("there is no ", columns[i], " in the table")
			var val = values[i]
			#if _is_valid_type(val, column_type[at]):
			elemen[at] = _retrieve(val, column_type[at])
		rows.append(elemen)
	
	func select(columns:PackedStringArray = []):
		if columns.size() != 0:
			pass
		else:
			return rows
	
	func _is_valid_type(value, type:DataType):
		match type:
			DataType.string:
				if value is String:
					return true
			DataType.number:
				if value is float or value is int:
					return true
				elif value is String:
					if (value as String).is_valid_float():
						return true
			DataType.bool:
				if value is bool:
					return true
				elif value is String:
					if value == "true" or value == "false":
						return true
			DataType.datetime:
				if value is Dictionary:
					var time = value as Dictionary
					if time["_"] == "datetime":
						return true
			_:
				printerr("undfined data type!", value)
		return false
	
	func _retrieve(value, expected_type:DataType):
		match expected_type:
			DataType.string:
				if value is String:
					return value
			DataType.number:
				if value is float or value is int:
					return value
				elif value is String:
					if (value as String).is_valid_float():
						return float(value)
			DataType.bool:
				if value is bool:
					return value
				elif value is String:
					if value == "true" :
						return true
					elif value == "false":
						return false
			DataType.datetime:
				if value is Dictionary:
					if(value as Dictionary)["_"] == "datetime":
						return value
				elif value is String:
					if value.right(2) == "()":
						var fun_name = value.substr(0, value.length()-2)
						match fun_name:
							"now":
								return Time.get_datetime_string_from_system()
			_:
				printerr("undfined data type!", value)
		return null

class Collection:
	var data:Array
	var has_function:Callable
	var equal_function:Callable
	
	func _init():
		pass
	
	func init(_data:Array, _has_function:Callable)->Collection:
		data = _data
		has_function = _has_function
		return self
	
	func fill(_data:Array):
		data = _data
	
	func set_equal_function(_equal_function:Callable):
		equal_function = _equal_function
	
	func set_has_function(_has_function:Callable):
		has_function = _has_function
	
	func get_data()->Array:
		return data
	
	func select_equal(selections:Array):
		var result:Array
		var selection_size:int = selections.size()
		for i in range(data.size()):
			var yes:bool = true
			for j in range(selection_size):
				if not has_function.call(data[i], selections[j]):
					yes = false
					break
			if yes:
				result.append(data[i])
				break
		return Collection.new().init(result, has_function)
	
	func select_or(selections:Array):
		var result:Array
		var selection_size:int = selections.size()
		for i in range(data.size()):
			for j in range(selection_size):
				if has_function.call(data[i], selections[j]):
					result.append(data[i])
					break
		return Collection.new().init(result, has_function)
	
	func select_and(selections:Array):
		var result:Array
		var selection_size:int = selections.size()
		for i in range(data.size()):
			var yes:bool = true
			for j in range(selection_size):
				if not has_function.call(data[i], selections[j]):
					yes = false
					break
			if yes:
				result.append(data[i])
		return Collection.new().init(result, has_function)

func forEach(function:Callable, elements:Array):
	var result:Array
	result.resize(elements.size())
	for i in range(elements.size()):
		result[i] = function.call(elements[i])
	return result

func softmax(numbers:PackedFloat64Array)->PackedFloat64Array:
	var size = numbers.size()
	var exp:PackedFloat64Array
	var total:float = 0.0
	exp.resize(size)
	for e in range(size):
		var res = pow(E, numbers[e])
		exp[e] = res
		total += res
	for e in range(size):
		exp[e] /= total
	return exp

func mean(numbers:PackedFloat64Array)->float:
	var size:int = numbers.size()
	var result:float = 0.0
	for num in numbers:
		result += num
	return result/size

func deviation(numbers:PackedFloat64Array)->float:
	var size:int = numbers.size()
	var mean:float = mean(numbers)
	var result:float = 0.0
	
	for i in range(size):
		result += pow( (mean-numbers[i]) , 2)
	
	return sqrt( result/size )

func minmax_normalization(numbers:PackedFloat64Array):
	var size:int = numbers.size()
	var min:float = self.min(numbers)
	var denominator:float = self.max(numbers) - min
	var results:PackedFloat64Array
	results.resize(size)
	for i in range(size):
		results[i] = (numbers[i] - min) / denominator
	return results

func batch_normalization(numbers:PackedFloat64Array):
	var size:int = numbers.size()
	var mean = mean(numbers)
	var denominator = deviation(numbers)
	var results:PackedFloat64Array
	results.resize(size)
	for i in range(size):
		results[i] = (numbers[i] - mean) / denominator
	return results

func min(numbers:PackedFloat64Array)->float:
	var min:float = numbers[0]
	for num in numbers:
		if num < min:
			min = num
	return min

func max(numbers:PackedFloat64Array)->float:
	var max:float = numbers[0]
	for num in numbers:
		if num > max:
			max = num
	return max

#func quicksort(array:Array):
#	pass

class Pointer:
	extends RefCounted
	var data
	func write(input):
		data = input
		return self
