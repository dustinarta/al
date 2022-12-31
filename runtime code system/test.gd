tool
extends EditorScript

var collection = []

# Called when the node enters the scene tree for the first time.
func _run():
	
	collection.resize(8)
	
	for i in range(8):
		collection[i] = Register.new()
	
#	print(collection)
	
	var e1 = Expression.new()
	e1.parse("collection[0].emit_signal(\"set_value\", 90)")
	e1.execute([], self)
	
	var e2 = Expression.new()
	e2.parse("collection[0].data")
	print(e2.execute([], self))
