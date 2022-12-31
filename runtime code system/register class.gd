extends Reference
class_name Register

export var data:String

signal get_value
signal set_value

func _init():
	self.connect("get_value", self, "_get_value")
	self.connect("set_value", self, "_set_value")

func _get_value()->String:
	return data

func _set_value(value):
	data = str(value)

func _to_string():
	return str(["Register", data])
