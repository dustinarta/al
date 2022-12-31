extends ScrollContainer

onready var container = $GridContainer
onready var my_json

signal delete_child
signal emit_json

func _ready():
	self.connect("delete_child", self, "_on_delete_child")
	self.connect("emit_json", self, "_emit_json")

func _on_delete_child(node):
	print(node.id)
	my_json["key"][node.id].clear()
	my_json["data"][node.id].clear()
	container.remove_child(node)
	print(my_json)

func _emit_json(json):
	my_json = json
