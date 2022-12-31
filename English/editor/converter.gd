tool
extends EditorScript


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _run():
	var fsrc:File = File.new()
	var fdst:File = File.new()
	
	fsrc.open("res://English/dataset.json", File.READ)
	fdst.open("res://English/dataset-key.json", File.WRITE)
	
	var old_data:Array = JSON.parse(fsrc.get_as_text()).result as Array
	var new_data:Dictionary = {}
	
	for data in old_data:
		new_data[data[0]] = data.slice(1, -1)
		
	fdst.store_string(JSON.print(new_data, "\t"))
	
	fsrc.close()
	fdst.close()
	
	print("Succes")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
