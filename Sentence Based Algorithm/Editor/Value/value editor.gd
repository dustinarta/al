extends Control


onready var itemlist:ItemList = $Container/Content/ItemList
onready var treenode:Tree = $Container/Tree


var data:Dictionary
var values

func _ready():
	
	
	var f = File.new()
	f.open("res://Sentence Based Algorithm/memory.json", File.READ)
	data = JSON.parse(f.get_as_text()).result as Dictionary
	values = data["value"]
	f.close()
	
	
	load_item()

func load_item():
	var tree = treenode.create_item()
	tree.set_text(0, "parent")
	var tree1 = treenode.create_item(tree)
	tree1.set_text(0, "child1")
	tree1.set_editable(0, true)
	var tree3 = treenode.create_item(tree1)
	tree3.set_text(0, "child3")
	var tree2 = treenode.create_item(tree)
	tree2.set_text(0, "child2")
	for k in values:
		itemlist.add_item(k)
