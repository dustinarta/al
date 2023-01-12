extends Control

onready var buttonmenu = $"Container/Editor/Button Menu"
onready var popupmenu = buttonmenu.get_popup()
onready var content_list = $Container/Content/VBox
onready var line = $Container/Editor/LineEdit

enum SPEECH_TYPE {
	Noun = 0,
	Pronoun = 1,
	Verb = 2,
	Adjective = 3,
	Adverb = 4,
	Conjunction = 5,
	Preposition = 6,
	Article = 7,
	Interjection = 8
}

var speeches = SPEECH_TYPE.keys()
var data:Array
var path:String = "res://English/dataset.json"

var current_type_string:Array
var current_type_int:Array

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.window_size = Vector2(600, 400)
	OS.set_window_title("(*)")
	
	var f = File.new()
	f.open(path, File.READ)
	if not f.is_open():
		printerr("File not found \"" + path + "\"")
		get_tree().quit()
	data = JSON.parse(f.get_as_text()).result as Array
	f.close()
	
	for s in speeches:
		popupmenu.add_item(s)
	popupmenu.connect("id_pressed", self, "_on_popupmenu_id_pressed")
	
	load_content()
	save_content()

func load_content()->void:
	if content_list.get_child_count() != 0:
		clear_content()
	
	for each in data:
		var label = Label.new()
		var s = each[0] + ": "
		for i in range(1, each.size()):
#			s += str(each[i]) + ", "
			s += speeches[each[i]] + ", "
		label.text = s
		content_list.add_child(label)
		
func add_content(new_content:Array)->void:
	var label = Label.new()
	var s = new_content[0] + ": "
	for i in range(1, new_content.size()):
#			s += str(each[i]) + ", "
		s += speeches[new_content[i]] + ", "
	label.text = s
	content_list.add_child(label)

func clear_content():
	for child in content_list.get_children():
		content_list.remove_child(child)

func save_content():
	var json = JSON.print(data, "\t")
	
	var f = File.new()
	f.open(path, File.WRITE)
	if not f.is_open():
		printerr("File can't be saved at \"" + path + "\"")
	f.store_string(json)
	f.close()
	
	
func _on_popupmenu_id_pressed(id: int):
	if not current_type_string.has(speeches[id]):
		current_type_string.append(speeches[id])
		buttonmenu.text = str(current_type_string)
		current_type_int.append(id)

func _on_Button_Save_pressed():
	save_content()

func _on_Button_Push_pressed():
	var key = line.text
	var new_content = []
	new_content.append(key)
	new_content.append_array(current_type_int)
	add_content(new_content)
	new_content.erase(0)
	data.append(new_content)
