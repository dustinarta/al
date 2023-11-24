@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var array:Array = [1, 2, 3]
	var new_array:Array = [null, null, null]
	var size:int = array.size()
	
	for i in range(size):
		new_array[i] = array[
			(i+2) % size
		]
	
	print(new_array)
