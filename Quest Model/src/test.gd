tool
extends EditorScript

#var dataset: Dictionary = load("res://dataset.json") as Dictionary

func _run():
	var file = File.new()
	file.open("res://src/dataset.json", File.READ)
	var json = JSON.parse(file.get_as_text()).result as Dictionary
	file.close()
	
#	file.open("res://src/dataset.json", File.WRITE)
#	file.store_string(JSON.print(json, "\t"))
	
	var me = Mind.new(json)
	var res = me.talk("Andy is a boy ")
	print(res)
#	me.save("res://src/kmjinince.json")
