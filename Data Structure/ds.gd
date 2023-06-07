@tool
extends Node

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
#			if _is_valid_type(val, column_type[at]):
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

func forEach(function:Callable, elements:Array):
	var result:Array
	result.resize(elements.size())
	for i in range(elements.size()):
		result[i] = function.call(elements[i])
	return result
