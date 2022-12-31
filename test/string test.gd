tool
extends EditorScript


func _run():
	var string = "Andy,"
	var pos = string[-1]
	print([",", "."].has(pos))
