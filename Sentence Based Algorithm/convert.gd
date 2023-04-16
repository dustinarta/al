@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var f = FileAccess.open("res://Sentence Based Algorithm/memory.json", FileAccess.READ)
	var data = JSON.parse_string(f.get_as_text())
	var classes = data["class"]
	f.close()
	
	for k in classes:
		var thisclass = classes[k]
		thisclass["_p"] = []
		for p in thisclass["_v"]:
			thisclass["_p"].append(p)
	
	f = FileAccess.open("res://Sentence Based Algorithm/memory.json", FileAccess.WRITE)
#	print(JSON.stringify(data, "\t"))
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
