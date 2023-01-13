extends Control

onready var speechmenu:MenuButton = $"Container/Editor/Button Menu"
onready var speechtypemenu:MenuButton = $"Container/Editor/Type Menu"
onready var popupmenu:Popup = speechmenu.get_popup()
onready var popuptypemenu:Popup = speechtypemenu.get_popup()
onready var content_list:VBoxContainer = $Container/Content_f/VBox
onready var line:LineEdit = $Container/Editor/LineEdit
onready var itemlist:ItemList = $Container/Content/ItemList
onready var file_open:FileDialog = $"Container/Menu/Button Open/FileDialogOpen"
onready var file_save:FileDialog = $"Container/Menu/Button Save As/FileDialogSave"
onready var alert:AcceptDialog = $Alert

enum SPEECH_TYPE {
	Noun = 0,
	Pronoun = 1,
	Verb = 2,
	Adjective = 3,
	Adverb = 4,
	Conjunction = 5,
	Preposition = 6,
	Interjection = 7
}

enum NOUN {
	Common
	Proper
	Idea
	Collective
}

enum PRONOUN {
	Relative
	Indefinite
	Demonstrative
	Possesive
	Intensive
}

enum VERB {
	Auxiliary
	Modal
	Action
	State
}

enum ADJECTIVE {
	Comparative
	Superlative
	Descriptive
	Determiner 
	Article
}

enum ADVERB {
	Frequency
	Manner
	Degree
	Order
}

enum CONJUNCTION {
	Coordinating 
	Subordinating
	Correlative
}

enum PREPOSITION {
	Location
	Time
	Direction 
	Instrument
}

enum INTERJECTION {
	
}

var speeches = SPEECH_TYPE.keys()
var speechlist = [NOUN.keys(), PRONOUN.keys(), VERB.keys(), ADJECTIVE.keys(), ADVERB.keys(), CONJUNCTION.keys(), PREPOSITION.keys(), INTERJECTION.keys()]
var data:Dictionary = {}
var path:String = "res://English/dataset-key2.json"

var current_type_string:Array
var current_type_int:Array = [[]]

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	OS.window_size = Vector2(600, 400)
	OS.set_window_title("(*)")
	
	for s in speeches:
		popupmenu.add_item(s)
	popupmenu.add_item("[Empty]")
	menu_ready()
	popupmenu.connect("id_pressed", self, "_on_popupmenu_id_pressed")
	
	file_open.rect_size.y = 400
	file_save.rect_size.y = 400
	
	load_file(path)
	item_ready()
	print(data)
#	alert_ready()

func menu_ready():
	var menu = PopupMenu.new()
	menu.name = "submenu"
	menu.add_item("1")
	menu.add_item("2")
	menu.add_item("3")
	menu.connect("id_pressed", self, "submenuclick")
	popupmenu.add_child(menu)
	popupmenu.add_submenu_item("sub submenu", "submenu")

func submenuclick(id):
	print(id)

func item_ready()->void:
	if itemlist.get_item_count() != 0:
		itemlist.clear()
	var keys = data.keys().duplicate()
	var values = data.values().duplicate()
	
#	each key
	for i in range(data.size()):
		var v = values[i]
		var s = keys[i] + ": ["
		var types = v[0]
#		each types
		for j in range(types.size()):
			s += str(speeches[types[j]])
			s += "("
			var each_type = v[j+1]
#			each types of speech
			for k in range(each_type.size()):
				s += str(speechlist[types[j]][each_type[k]])
				if k != each_type.size()-1:
					s += ", "
			if j != types.size()-1:
				s += "), "
			else:
				s += ")"
		s += "]"
#		s += str(types)
#		for j in values[i]:
##			s += str(each[i]) + ", "
#			s += speeches[int(j)] + ", "
		itemlist.add_item(s)

func item_add(key:String, _types:Array)->void:
	var s = key + ": "
#	s += str(types)
#	for i in range(types.size()):
##			s += str(each[i]) + ", "
#		s += speeches[types[i]] + ", "
	s += str(current_type_string)
	var pos = data.keys().find(key)
	if pos == -1:
		itemlist.add_item(s)
	else:
		itemlist.set_item_text(pos, s)

func load_file(path:String)->void:
	if not path.ends_with(".json"):
		alert_show("Bukan file json bodoh!")
		return
	var f = File.new()
	f.open(path, File.READ)
	if not f.is_open():
		alert_show("File gak bisa dibuka : \"" + path + "\"")
#		printerr("File not found \"" + path + "\"")
		path = ""
		return
	data = JSON.parse(f.get_as_text()).result as Dictionary
	f.close()
	OS.set_window_title(path)

func save_file(path:String)->void:
	if data.size() == 0:
		alert_show("Isinya kosong ya ngapain di save!")
		return
	elif not path.ends_with(".json"):
		alert_show("Bukan file json bodoh!")
		return
	
	var json = JSON.print(data, "\t")
	var f = File.new()
	f.open(path, File.WRITE)
	if not f.is_open():
		alert_show("File gak bisa dibuka : \"" + path + "\"")
		return
	f.store_string(json)
	f.close()
	self.path = path
	OS.set_window_title(path)

func _on_popupmenu_id_pressed(id: int)->void:
	menu_add_speech(id)
	
func menu_add_speech(id: int)->void:
	if id == 8:
		current_type_int.clear()
		current_type_int = [[]]
		current_type_string.clear()
		speechmenu.text = "Type"
		return
	print(id)
	if not current_type_int[0].has(id):
		current_type_string.append(speeches[id])
		current_type_int[0].append(id)
		current_type_int.append([])
		menu_update_speech()

func menu_update_speech():
	var s:String
	var types = current_type_int[0]
	s += "["
	for i in range(types.size()):
		s += speeches[types[i]]
		for j in range(current_type_int[i + 1].size()):
			s += "(" + str(speechlist[i][j]) + ")"
		if i != types.size()-1:
			s += ", "
	s += "]"
	speechmenu.text = s

func _on_Button_Save_pressed()->void:
	if path == "":
		_on_Button_Save_As_pressed()
	else:
		save_file(path)

func is_valid_key(key:String)->bool:
	if key.is_valid_identifier():
		for n in "0123456789":
			if key.find(n) != -1:
				return false
	else:
		return false
	return true

func _on_Button_Push_pressed()->void:
	var key = line.text
	
	if key == "":
		return
	elif current_type_int.empty():
		alert_show("Pake tipe dong!")
		return
	elif not is_valid_key(key):
		alert_show("Gak bisa nulis \"" + key + "\"")
		return
	item_add(key, current_type_int)
	data[key] = current_type_int.duplicate()
	print("Memasukkan " + key + " data " + str(current_type_int))
	
	current_type_int.clear()
	current_type_int = [[]]
	current_type_string.clear()
	speechmenu.text = "Type"
	line.text = ""

func _on_ItemList_nothing_selected()->void:
	itemlist.unselect_all()

func type_int_to_string(types:Array)->Array:
	var result = []
	var v = types[0]
	result.resize(v.size())
	for i in range(v.size()):
		result[i] = speeches[v[i]]
	return result

func editor_set(index:int):
	line.text = data.keys()[index]
	current_type_int = data.values()[index].duplicate()
	current_type_string = type_int_to_string(current_type_int)
	speechmenu.text = str(current_type_string)

func _on_ItemList_item_activated(index):
#	print(data)
	editor_set(index)

func _on_FileDialogOpen_file_selected(path):
	load_file(path)
	item_ready()
	self.path = path

func _on_Button_Open_pressed():
	file_open.popup_centered()

func alert_show(msg):
	alert.dialog_text = msg
	alert.show()

func alert_ready():
	alert.rect_position = (OS.window_size - alert.rect_size) / 2

func _on_FileDialogSave_file_selected(path):
	save_file(path)

func _on_Button_Save_As_pressed():
	file_save.popup_centered()


func _sts_noun(id:int):
	menu_add_speech(0)
	var pos: int = (current_type_int[0] as Array).find(0)
	(current_type_int[pos + 1] as Array).append(id)
	menu_update_speech()

