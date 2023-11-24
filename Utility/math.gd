extends RefCounted
class_name Math

enum EntityType {
	NUMBER,
	VARIABLE,
	EQUATION
}

enum Operator {
	PLUS, MINUS, MULTIPLY, DEVIDE,
	FRACTION, POWER, LOG
}

class Entity:
	extends RefCounted
	var type:EntityType

class Number:
	extends Entity
	var value:float
	func _init(_value:float = 0.0):
		value = _value
	func set_value(_value:float):
		value = _value
		return self
	func _to_string():
		return "Number: " + str(value)

class Variable:
	extends Entity
	var name:String
	func set_variable(_name:String):
		name = _name
		return self

class Equation:
	extends Entity
	
	var is_bracket:bool
	var left_entity:Entity
	var operator:Operator
	var right_entity:Entity
	
	func evaluate()->Entity:
		if left_entity.type == EntityType.NUMBER and right_entity.type == EntityType.NUMBER:
			var this_left = left_entity as Number
			var this_right = right_entity as Number
			var result = Number.new()
			match operator:
				Operator.PLUS:
					result.value = this_left.value + this_right.value
			return result
		return null
	

func parse(formula:String):
	var each = formula.split(" ", false)
	var equation = Equation.new()
#	for i in range(each.size()):
#
	
	
