tool
extends EditorScript

var path:String = "res://English/dataset-key.json"
var newpath:String = "res://English/dataset-key2.json"

func _run():
#	
	var f = File.new()
	f.open(path, File.READ)
	var s = f.get_as_text()
	var o = JSON.parse(s).result as Dictionary
	
	for key in o.keys():
		var a = o[key] as Array
		var value = a.duplicate(true)
		a.resize(value.size()+1)
		a[0] = value
		for j in range(1, value.size()+1):
			a[j] = []
#		print(a)
	
	f.close()
	f = File.new()
	f.open(newpath, File.WRITE)
	s = JSON.print(o, "\t", true)
	f.store_string(s)
	f.close()
#	print(s)
	
#	print(o)
	
	
