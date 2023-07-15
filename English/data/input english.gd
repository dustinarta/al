extends Control

@onready var textedit:TextEdit = $VBoxContainer/TextEdit

var memory:Dictionary
var path:String = "res://English/data/english.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.load(path)

func _on_button_pressed():
	append_string(
		split_string(
			textedit.text.to_lower()
		)
	)
	self.save(path)

const SPESIAL_CHAR = [
	',', '.', ';', ':', '\'', '"', '-', '_', '?', '!', '@', '#', '$', '%', '*', '^', '&'
]

func append_string(packedstring:PackedStringArray):
	for s in packedstring:
		if memory.has(s):
			continue
		else:
			memory[s] = memory.size()

func split_string(s:String):
	var split = s.split(" ")
	var result:PackedStringArray
	
	for i in range(split.size()):
		var string:String = split[i]
		var char = string[-1]
		if SPESIAL_CHAR.has(char):
			string = string.substr(0, -2)
		result.append(string)
	
	return result

func save(path:String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(
		JSON.stringify(memory, "\t", false)
	)
	file.close()

func load(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	memory = JSON.parse_string(
		file.get_as_text()
	)
	file.close()
