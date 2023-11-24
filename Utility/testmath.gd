@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var equation = Math.Equation.new()
	equation.left_entity = Math.Number.new(1)
	equation.operator = Math.Operator.PLUS
	equation.right_entity = Math.Number.new(2)
	print(equation.evaluate())
