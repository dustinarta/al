extends Control


@onready var classnamelabel = $"VBoxContainer/Data Editor/Class Edit/Panel/VBoxContainer/class_name/name"
@onready var classproperty = $"VBoxContainer/Data Editor/Class/Panel/VBoxContainer/self property/ScrollContainer/properties"
@onready var classlist = $"VBoxContainer/Data Editor/Class Edit/Panel/VBoxContainer/instance/classes"
@onready var classtree = %"Class Tree"
@onready var propertyparenttree:Tree = $"VBoxContainer/Data Editor/Class Edit/Panel/VBoxContainer/parent property/Tree"
@onready var propertyselftree:Tree = $"VBoxContainer/Data Editor/Class Edit/Panel/VBoxContainer/self property/Tree"
@onready var window = get_window()

@onready var new_class = $"VBoxContainer/Data Editor/Class Edit/Panel/VBoxContainer/new class"
@onready var createclasslist:PopupMenu = $"VBoxContainer/Data Editor/Class Edit/Panel/VBoxContainer/new class/instance".get_popup()
@onready var edit_class = $"VBoxContainer/Data Editor/Class Edit/Panel/VBoxContainer/edit class"

var sbaclass:Dictionary
var rootpropertyparent:TreeItem
var rootpropertyself:TreeItem
var thisclass
var thisclassinstance
var thisselfproperty
var treeitemdata:Dictionary
var rootclass:TreeItem

func _ready():
	SBA.init()
	sbaclass = SBA.Classes
	window.size = Vector2(1000, 600)

	load_class()
	load_class_tree()
	print(typeof(null))
#	class_select("thing")
	var classinstancepopup:PopupMenu = $"VBoxContainer/Data Editor/Class Edit/Panel/VBoxContainer/new class/instance".get_popup()
	classinstancepopup.connect("id_pressed", instance_pick)

func update_parent_property(property:Dictionary):
	propertyparenttree.clear()
	rootpropertyparent = propertyparenttree.create_item()
	propertyparenttree.hide_root = true
	for k in property:
		var treeitem = propertyparenttree.create_item(rootpropertyparent)
		treeitem.set_text(0, k)
		treeitem.collapsed = true
		var value = property[k]["_v"]
		if value != null:
			var childtree = propertyparenttree.create_item(treeitem)
			childtree.set_text(0, str(value))
			childtree.collapsed = true

#		var child = propertyparentree.create_item(treeitem)
#		child.set_text(0, "value")
#		child.set_editable(0, true)

func update_self_property(varclass:Dictionary):
	var property = varclass["_p"]
	var values = varclass["_v"]
	thisselfproperty = values
	print(thisselfproperty)
	propertyselftree.clear()
	rootpropertyself = propertyselftree.create_item()
	propertyselftree.hide_root = true
	for k in property:
		if values.has(k):
			continue
		var treeitem = propertyselftree.create_item(rootpropertyself)
		treeitem.set_text(0, k)
		treeitem.collapsed = true
	for k in values:
		var treeitem = propertyselftree.create_item(rootpropertyself)
		treeitem.set_text(0, k)
		treeitem.collapsed = true
		var value = values[k]["_v"]
		if value != null:
			var childtree = propertyselftree.create_item(treeitem)
			childtree.set_text(0, str(value))
			childtree.collapsed = true

func add_self_property(name:String, data:Dictionary):
	pass

func generate_classdata(classname:String):
	var data = {
		"_n": classname,
		"_c": sbaclass[classname]["_c"],
		"_v": SBA._instance_properties_values(classname)
	}
	return data

func load_class():
	var classpopup:PopupMenu = classlist.get_popup()
	createclasslist.clear()
	classpopup.clear()
	for k in sbaclass:
		createclasslist.add_item(k)
		classpopup.add_item(k)

func load_class_tree(index:int = 0):
	var keys = sbaclass.keys()
	for k in range(index, keys.size()):
		var key = keys[k]
		
		#loading parent class
#		print(key)
		_load_parent_class(key)
	classtree.hide_root = true

func _load_parent_class(classname:String):
	if treeitemdata.has(classname):
		return
	var varclass = sbaclass[classname]
	var parentclass = varclass["_c"]
	if parentclass == null:
		var thistree:TreeItem = classtree.create_item(rootclass)
		thistree.set_text(0, classname)
		treeitemdata[classname] = thistree
		return
	
	if not treeitemdata.has(parentclass):
		_load_parent_class(parentclass)
	var thistree:TreeItem = classtree.create_item(treeitemdata[parentclass])
	thistree.set_text(thistree.get_child_count(), classname)
	thistree.collapsed = true
	treeitemdata[classname] = thistree

#func class_select(_name:String):
#	if !sbaclass.has(_name):
#		printerr("Class \"" + _name + "\" doesn't exist")
#	if classproperty.item_count > 0:
#		print("clear property")
#		classproperty.clear()
#		print(classproperty.item_count)
#	var data = sbaclass[_name]
#	classnamelabel.text = _name
#	classinstance.get_child(1).text = str(data["_c"])
#
#	var property = data["_v"]
#	var propk = property.keys()
#	var propv = property.values()
#	for i in range(propk.size()):
#		classproperty.add_item(propk[i])

func property_edit_setup(name:String, value = null):
	pass

func class_inherit(name:String, parent:String):
	var mydata = generate_classdata(parent)
	mydata["_n"] = name
	mydata["_c"] = parent
	return mydata

func class_setup(data:Dictionary):
	$"VBoxContainer/Data Editor/Class Edit/Panel/VBoxContainer/class_name/name".text = data["_n"]
	classlist.text = str(data["_c"])

func class_clicked(id):
	var keys  = sbaclass.keys()[id]
	var data = generate_classdata(keys)
	print("chosen ", keys)
	class_setup(data)
	update_parent_property(data["_v"])

func _on_button_save_pressed():
	SBA.save(SBA.path)

func _on_class_list_item_activated(index):
	print(index)
	class_clicked(index)

func _on_add_class_pressed():
	var classname = new_class.get_child(0).text
	var classparent = new_class.get_child(1).text
	thisclass = class_inherit(classname, classparent)
	class_setup(thisclass)
	update_parent_property(thisclass["_v"])
	toggle_classgui()

func toggle_classgui():
	if new_class.visible:
		new_class.hide()
		edit_class.show()
	else:
		edit_class.hide()
		new_class.show()

func _on_button_pressed():
	toggle_classgui()

func instance_pick(id):
	var keys = sbaclass.keys()[id]
	thisclassinstance = keys
	$"VBoxContainer/Data Editor/Class Edit/Panel/VBoxContainer/new class/instance".text = keys

func _on_class_tree_item_activated():
	var treeitem:TreeItem = classtree.get_selected()
	var key = treeitem.get_text(0)
	var data = generate_classdata(key)
	class_setup(data)
	data = generate_classdata(data["_c"])
	update_parent_property(data["_v"])
	update_self_property(sbaclass[key])

func _on_self_property_tree_item_activated():
	var name = propertyselftree.get_selected().get_text(propertyselftree.get_selected_column())
	print(name)
