extends Control

onready var speechmenu:MenuButton = $"Container/Editor/Button Menu"
onready var speechtypemenu:MenuButton = $"Container/Editor/Type Menu"
onready var popupmenu:Popup = speechmenu.get_popup()
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
	Second
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

var current_type_int:Array = [[]]

# Called when the node enters the scene tree for the first time.
func _ready()->void:
	OS.window_size = Vector2(600, 400)
	OS.set_window_title("(*)")
	alert_ready()
	menu_ready()
	popupmenu.add_item("[Empty]")
	popupmenu.connect("id_pressed", self, "_on_popupmenu_id_pressed")
	
	file_open.rect_size.y = 400
	file_save.rect_size.y = 400
	
	load_file(path)
	item_ready()
#	print(data)
	

func menu_ready():
	var menus:Array
	menus.resize(8)
	
	for i in range(8):
		menus[i] = PopupMenu.new()
	
	for j in range(menus.size()):
		var m = menus[j]
#		print(m)
		var speech = speechlist[j] as Array
		m.name = "menu" + str(speeches[j])
		for i in range(speech.size()):
			m.add_item(speech[i])
#		print(m.get_item_count())
		m.connect("id_pressed", self, "_sts_" + str(speeches[j]))
		popupmenu.add_child(m)
		popupmenu.add_submenu_item(str(speeches[j]), "menu" + str(speeches[j]))

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
			var each_type = v[j+1]
			var etl:int = each_type.size()
			if etl != 0:
				s += "("
#			each types of speech
			for k in range(etl):
				s += str(speechlist[types[j]][each_type[k]])
				if k != etl-1:
					s += ", "
			if etl != 0:
				s += ")"
			if j != types.size()-1:
				s += ", "
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
	s += speech_parse_string()
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
		alert_show("Isinya kosong!")
		return
	elif not path.ends_with(".json"):
		alert_show("Bukan file json!")
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
	print("menu " + str(id))
	menu_add_speech(id)
	
func menu_add_speech(id: float)->void:
	print(current_type_int)
	if id == 8:
		current_type_int.clear()
		current_type_int = [[]]
		menu_update_speech()
		return
#	print(id)
	if not current_type_int[0].has(id):
		current_type_int[0].append(id)
		current_type_int.append([])
		print(id)
		print(current_type_int)
		menu_update_speech()

func menu_update_speech():
	var s:String = speech_parse_string()
	if s == "[]":
		s = "Type"
	speechmenu.text = s

func speech_parse_string() -> String:
	var s:String
	var types = current_type_int[0]
	
	s += "["
	for i in range(types.size()):
		s += speeches[types[i]]
		var each_type = current_type_int[i + 1]
		var etl = each_type.size()
		for j in range(etl):
			if j == 0:
				s += "("
			else:
				s += ", "
			s += str(speechlist[types[i]][each_type[j]])
			if j == etl - 1:
				s += ")"
		if i != types.size()-1:
			s += ", "
	s += "]"
	return s

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
	elif current_type_int[0].empty():
		alert_show("Tipe tidak boleh kosong!")
		return
	elif not is_valid_key(key):
		alert_show("Gak bisa nulis \"" + key + "\"")
		return
	print(current_type_int)
	item_add(key, current_type_int)
	data[key] = current_type_int.duplicate()
	print("Memasukkan \"" + key + "\": " + speech_parse_string())
	
	current_type_int.clear()
	current_type_int = [[]]
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
#	print(current_type_int)
#	current_type_string = type_int_to_string(current_type_int)
	menu_update_speech()

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
	alert.popup_centered(Vector2(200, 100))

func alert_ready():
	alert.window_title = "Peringatan!"
	alert.rect_position = (OS.window_size - alert.rect_size) / 2

func _on_FileDialogSave_file_selected(path):
	save_file(path)

func _on_Button_Save_As_pressed():
	file_save.popup_centered()

func sts_add_menu(sid:float, id:float):
	menu_add_speech(sid)
	var pos: int = (current_type_int[0] as Array).find(sid)
	var loc = current_type_int[pos + 1] as Array
	if !loc.has(id):
		loc.append(id)
	menu_update_speech()

func _sts_Noun(id:int):
	var sid = 0
	sts_add_menu(sid, id)

func _sts_Pronoun(id:int):
	var sid = 1
	sts_add_menu(sid, id)

func _sts_Verb(id:float):
	var sid = 2
	sts_add_menu(sid, id)

func _sts_Adjective(id:int):
	var sid = 3
	sts_add_menu(sid, id)

func _sts_Adverb(id:int):
	var sid = 4
	sts_add_menu(sid, id)

func _sts_Conjunction(id:int):
	var sid = 5
	menu_add_speech(sid)
	var pos: int = (current_type_int[0] as Array).find(sid)
	var loc = current_type_int[pos + 1] as Array
	if !loc.has(id):
		loc.append(id)
	menu_update_speech()
	
func _sts_Preposition(id:int):
	var sid = 6
	sts_add_menu(sid, id)

func _sts_Interjection(id:int):
	var sid = 7
	sts_add_menu(sid, id)


func _on_Button_Find_pressed():
	var text = line.text
	var index = data.keys().find(text)
	
	if index == -1:
		alert_show("\"" + text + "\" tidak ditemukan!")
	else:
		itemlist.select(index)
		editor_set(index)
