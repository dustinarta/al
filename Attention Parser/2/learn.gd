extends Control

@onready var Elements:HBoxContainer = %elementcontainer
@onready var Phrases:HBoxContainer = %phrasecontainer
@onready var InputText:TextEdit = %inputtext
var thisap
var WordData:PackedScene = load("res://Attention Parser/2/word_data.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	thisap = AP2.new()
	thisap.load("res://Attention Parser/2/data.json")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func clear_child(node:Node):
	for child in node.get_children():
		node.remove_child(child)

func add_element(word:String, type:String):
	var element = WordData.instantiate()
	Elements.add_child(element)
	element.MyWord = word
	if type:
		print("here ", thisap.Types_d[type])
		element.select_type( thisap.Types_d[type] )

func update_elements(words:PackedStringArray, types:PackedStringArray):
	clear_child(Elements)
	for i in range(words.size()):
		add_element(words[i], types[i])

func collect_elements()->Array:
	var children:Array[Node] = Elements.get_children()
	var size = children.size()
	var words:PackedStringArray
	var types:PackedStringArray
	words.resize(size)
	types.resize(size)
	for i in range(size):
		words[i] = children[i].MyWord
		types[i] = children[i].ThisType
	
	return [words, types]

func add_phrase(phrase:AP2.Phrase):
	pass

func update_phrases(packedphrase:AP2.PackedPhrase):
	pass

func _on_inputbutton_pressed():
	var text = InputText.text
	var words:PackedStringArray = thisap.parse_word(text)
	var types:PackedStringArray = thisap.read(text)
	var packedphrase = thisap.parse_phrase(words, types)
	update_elements(
		words, types
	)
	
	print(thisap.parse_word(text))
	InputText.text = ""


func _on_learnbutton_pressed():
	print(
		collect_elements()
	)
