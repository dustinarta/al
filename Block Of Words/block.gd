@tool
extends Control


@export var word:String: set = set_word
@export var align:ALIGN: set = set_label_align
@export var child:PackedScene: set = set_child

@onready var _label = $panel/container/label
@onready var _container = $panel/container

var parent:Node


func _ready():
	pass # Replace with function body.



func set_word(value):
	word = value
	if _label == null:
		return
	_label.text = word

func add_new_child(node: Node, align:ALIGN):
	_container.add_child(node)
	$panel.size.x = _label.size.x + node.size.x
#	node.position.x -= node.size.x
	$panel.size.y += 20
#	$panel.position.y -= 10
#	_container.size.y += 20
	if align == ALIGN.Left:
		_container.move_child(node, 0)
		node.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	elif align == ALIGN.Right:
		_container.move_child(node, 1)
		node.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	node.parent = self

func set_label_align(value):
	if _container.get_child_count() == 1:
		return
	else:
		if _container.get_child(0) is Label:
			if value == ALIGN.Right:
				_container.move_child(_label, 1)
		else:
			if value == ALIGN.Left:
				_container.move_child(_label, 0)
	align = value

func set_child(value:PackedScene):
	print(value.instantiate().word)

enum ALIGN{
	Left,
	Right
}
