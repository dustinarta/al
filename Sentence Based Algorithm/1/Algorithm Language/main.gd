extends Control

@onready var lineedit = $Container/Command/LineEdit
@onready var resultbox = $Container/Result

var resultpackedscene:PackedScene = preload("res://Sentence Based Algorithm/Algorithm Language/block.tscn")
var window:Window = get_window()
var allow_execute:bool = true
var is_onfocus:bool = false

func _ready():
	window = get_window()
	window.size = Vector2(600, 400)
	var node = Node.new()
	
	English.init(English.path)

func _input(event):
	if is_onfocus:
		if Input.is_key_pressed(KEY_ENTER):
			read(lineedit.text)

func read(s:String):
	if allow_execute == false:
		return
	if lineedit.text == "":
		lineedit.placeholder_text = "Expected Input"
		return
	
	var result = English.read(s).phrases
	
	_remove_children(resultbox)
	
	for i in range(result.size()):
		var resultscene = resultpackedscene.instantiate()
		resultbox.add_child(resultscene)
		resultscene.set_up(result[i])
	
	allow_execute = false
	var tween = create_tween()
	
	tween.tween_property(self, "allow_execute", true, 5.0)

func _on_ButtonPush_pressed():
	read(lineedit.text)

func _remove_children(node:Node):
	var children = node.get_children()
	for i in range(node.get_child_count()):
		node.remove_child(children[i])

func _on_LineEdit_text_entered(new_text):
	read(lineedit.text)

func _on_line_edit_focus_entered():
	is_onfocus = true

func _on_line_edit_focus_exited():
	is_onfocus = false

func refocus():
	allow_execute = true
