extends Control


@onready var handle_word:Label = %word
@onready var handle_type:OptionButton = %type

@export var MyWord:String :set = set_word
@export var MyType:String :set = set_type
@export var ThisType:String

var Types:Dictionary
var Types_count:int
var Types_s:PackedStringArray
var Types_v:PackedStringArray
var Types_d:Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	Types = JSON.parse_string(
		FileAccess.open("res://Attention Parser/2/data.json", FileAccess.READ).get_as_text()
	)["types"]
	setup_types()
	for type in Types.values():
		handle_type.add_item(type)

func setup_types():
	Types_count = Types.size()
	Types_s = Types.keys()
	Types_v = Types.values()
	for i in range(Types_count):
		Types_d[Types_s[i]] = i

func _init(word:String = "", type:String = ""):
	if word:
		MyWord = word
	if type:
		MyType = type

func set_word(word:String):
	MyWord = word
	handle_word.text = word

func select_type(idx):
	MyType = Types_v[idx]
	ThisType = Types_s[idx]
	handle_type.select(idx)

func set_type(type:String):
	MyType = type
	handle_type.text = type

func set_word_and_type(word:String, type:String):
	MyWord = word
	MyType = type


func _on_type_item_selected(index):
	select_type(index)
