tool
extends EditorScript

var new_json_path = "res://English/dataset2.json"
var old_json_path = "res://English/dataset-key.json"
var output_path = "res://English/dataset-key.json"

func _run():
	var new_json:Dictionary = {}
	var old_json:Dictionary = {}
	var new_json_keys
	var old_json_keys
	
	var f:File
	var s
	
	f = File.new()
	f.open(new_json_path, File.READ)
	new_json = JSON.parse(f.get_as_text()).result as Dictionary
	f.close()
	
	f = File.new()
	f.open(old_json_path, File.READ)
	old_json = JSON.parse(f.get_as_text()).result as Dictionary
	f.close()
	
	new_json_keys = new_json.keys()
	old_json_keys = old_json.keys()
	
	for key in new_json_keys:
		old_json[key] == new_json[key]
			
	
	f = File.new()
	f.open(output_path, File.WRITE)
	var output = JSON.print(old_json, "\t")
	f.store_string(output)
	f.close()
	
	print("Success")
