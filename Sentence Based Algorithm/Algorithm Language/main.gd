extends Control

onready var lineedit = $Container/Command/LineEdit
onready var resultbox = $Container/Result

var resultpackedscene:PackedScene = preload("res://Sentence Based Algorithm/Algorithm Language/block.tscn")


func _ready():
	OS.window_size = Vector2(600, 400)
	var node = Node.new()
	
	English.init()

func read(s:String):
	if lineedit.text == "":
		lineedit.placeholder_text = "Expected Input"
		return
	
	var result = English.read(s).phrases
	
	_remove_children(resultbox)
	
	for i in range(result.size()):
		var resultscene = resultpackedscene.instance()
		resultbox.add_child(resultscene)
		resultscene.set_up(result[i])

func _on_ButtonPush_pressed():
	read(lineedit.text)

func _remove_children(node:Node):
	var children = node.get_children()
	for i in range(node.get_child_count()):
		node.remove_child(children[i])

func _on_LineEdit_text_entered(new_text):
	read(lineedit.text)
