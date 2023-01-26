extends Control

onready var itemlist = $Container/Content/ItemList

var data
var path = "res://English/src/inheritance.json"

func _ready():
	var f = File.new()
	f.open(path, File.READ)
	data = JSON.parse(f.get_as_text()).result as Dictionary
	
	load_item()

func load_item():
	for k in data:
		if k == "_meta":
			continue
		add_item(k, data[k])
	
func add_item(key:String, meta):
	var s:String = ""
	s += key + ": extends = " + str(meta[0]) + ", properties = " + str(meta[1])
	itemlist.add_item(s)
