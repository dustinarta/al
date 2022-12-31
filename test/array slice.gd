tool
extends EditorScript


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _run():
	var array = [1, 23, 4, 5, 8, 6, 7, 89, 90]
	
	print(array.slice(2, -1))
	print(array)
