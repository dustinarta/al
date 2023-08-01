@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var oldpath:String = "res://English/data/english.json"
	var newpath:String = "res://English/data/english2.json"
	var file = FileAccess.open(oldpath, FileAccess.READ)
	var data:Dictionary = JSON.parse_string(
		file.get_as_text()
	)
	file.close()
	
	var newdata:Dictionary = {}
	var keys:PackedStringArray = data.keys()
	for i in range(data.size()):
		var key = keys[i]
		if key == "":
			continue
		if key.contains("_"):
			var split = key.split("_", false)
			for s in split:
				if !newdata.has(s):
					newdata[s] = newdata.size() + 1
		else:
			if !newdata.has(key):
				newdata[key] = newdata.size() + 1
	
	file = FileAccess.open(newpath, FileAccess.WRITE)
	file.store_string(
		JSON.stringify(
			newdata, "\t", false
		)
	)
	file.close()
	print("done")
