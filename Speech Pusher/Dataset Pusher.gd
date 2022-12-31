extends Control

onready var datakey_src = preload("res://Speech Pusher/DataLine.tscn")
onready var open_dialog = $Panel/Container/Menu/btnOpen/openDialog
onready var save_dialog = $Panel/Container/Menu/btnSaveas/saveasDialog
onready var line = $Panel/Container/Edit/LineEdit
onready var Edit = $Panel/Container/Edit
onready var data_container = $Panel/Container/Data/GridContainer


export var my_json:Dictionary
var keys:Array
var json_data:Array
var my_json_path:String

func _ready():
	OS.set_window_title("(*)")
	OS.set_window_size(Vector2(600, 400))
	_on_openDialog_file_selected("res://src/dataset.json")
	data_container.get_parent().emit_signal("emit_json", my_json)


func sort():
	pass

func _on_btnOpen_pressed():
	open_dialog.popup()

func _on_openDialog_file_selected(path:String)->void:
	if not path.ends_with(".json"):
		print("Can't open non json file")
		return
		
	if data_container.get_child_count() > 0:
		queue_free_children(data_container)
	
	OS.set_window_title(path)
	var file:File = File.new()
	file.open(path, File.READ)
	if not file.is_open():
		printerr("Couldn't open " + path)
		return
	my_json_path = path
	var json_file = JSON.parse(file.get_as_text()).result as Dictionary
	file.close()
	self.keys = json_file["key"]
	for key in self.keys:
		push_data(key[0], key[1])
	self.my_json = json_file
	self.json_data = self.my_json["data"]
	
func push_data(key:String, id:int)->void:
	var data_line = datakey_src.instance()
	data_container.add_child(data_line)
	data_line.emit_signal("set_up", [key, id])

func _on_btnPush_pressed()->void:
	if line.text.empty():
		Edit.emit_signal("clean")
		return
	var _data = [line.text, keys.size()]
	var index = has_empty()
#	print(index)
	if index == -1:
		keys.push_back(_data)
		json_data.push_back({"_n" : _data[0], "_st" : Edit.this_speech_int})
		push_data(_data[0], _data[1])
	else:
		keys[index] = [_data[0], index]
		json_data[index] = {"_n" : _data[0], "_st" : Edit.this_speech_int}
		push_data(_data[0], index)
		
	Edit.emit_signal("clean")
	line.placeholder_text = line.text
	line.set_text("")

func _on_btnSave_pressed():
	var file = File.new()
	file.open(my_json_path, File.WRITE)
	file.store_string(JSON.print(my_json, "\t"))
	file.close()

func _on_saveasDialog_file_selected(path):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(JSON.print(my_json, "\t"))
	file.close()

func _on_btnSaveas_pressed():
	save_dialog.popup()

static func queue_free_children(node: Node)->void:
	for child in node.get_children():
		child.queue_free()

func has_empty()->int:
	var keys = my_json["key"]
	for id in range(keys.size()):
		if keys[id].empty():
			return id
	return -1
