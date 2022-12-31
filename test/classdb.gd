tool
extends EditorScript

class sus:
	var obj:String = "190"

# Called when the node enters the scene tree for the first time.
func _run():
	var class_list = ClassDB.get_class_list()
	var sus1 = sus.new()
	print(class_list.has("sus"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
