tool
extends EditorScript



func _run():
	var s = "He is running every morning"
	
#	print(English.get_method_list())
	
	English.init()
	
	print(English.read(s))
