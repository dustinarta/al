tool
extends EditorScript

var public = 99

func _run():
	var e = Expression.new()
#	print( e.parse("print(\"emongus\")", ["e"]) )
#	print(e.execute([7]))
	var my_data:Array
	var register:Array
	var expressions = []
	e.parse("print(my_function())", [])
	e.execute([], self)

func my_function():
	print("ejv9ieiufh")
	return 90
