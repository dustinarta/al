@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
#	English._has_init = false
	English.init(English.path)
	var sba = SBA3.new()
#	sba.read("i have a black cat")
	sba.read("cat, duck, and dog are animal in my house")
#	sba.read("he is a man if i run")
#	var collection = English.read("i have a black cat in my house")
#	print(collection)
#	sba.parse_phrase(collection)
