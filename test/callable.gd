@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var lamda = func():
		print("omaga")
	print(lamda)
