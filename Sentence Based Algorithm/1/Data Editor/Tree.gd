extends Tree


@onready var parent = get_node("/root/main")
signal load_property
var root

# Called when the node enters the scene tree for the first time.
func _ready():
	root = create_item()
	hide_root = true
	SBA.init()
	var sbaclass = SBA.Classes
	
	connect("load_property", update_property)

func update_property(classname:String):
	clear()
	root = create_item()
	var property = SBA._instance_properties(classname)
	for k in property:
		var treeitem = create_item(root)
		treeitem.set_text(0, k + ": " + str(property[k]["_v"]))
		treeitem.collapsed = true
		var child = create_item(treeitem)
		child.set_text(0, "value")
		child.set_editable(0, true)
	

func _on_item_activated():
	print("Selected ", get_selected().get_text(0))
