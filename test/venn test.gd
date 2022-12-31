tool
extends EditorScript


var Venn = load("res://src/venn.gd").new()


func _run():
	var r = Venn.operate([1, 2, 3], [5, 2, 3, 4], Venn.INTERSECTION)
	print(r)

