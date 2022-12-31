extends Control

onready var editor = $"%Editor"
onready var option_type = $"%Option_Type"

var scene_on_editor = null

# Called when the node enters the scene tree for the first time.
func _ready():
	option_type_start()
	print(editor.scene_list)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func option_type_start():
	option_type.add_item("--Type--")
	option_type.add_item("Noun")
	option_type.add_item("Pronoun")
	option_type.add_item("Verb")
	option_type.add_item("Adjective")
	option_type.add_item("Adverb")
	option_type.add_item("Conjunction")
	option_type.add_item("Preposition")
	option_type.add_item("Intersection")

enum {
	TYPE_NOUN = 1,
	TYPE_PRONOUN = 2,
	TYPE_VERB = 4,
	TYPE_ADJECTIVE = 8,
	TYPE_ADVERB = 16,
	TYPE_CONJUNCTION = 32,
	TYPE_PREPOSITION = 64,
	TYPE_INTERSECTION = 128,}

func _on_Option_Type_item_selected(index):
	var scene_index = index-1
	
	if scene_on_editor != null:
		scene_on_editor.queue_free()
	
	scene_on_editor = editor.scene_list[scene_index].instance()
	editor.add_child_below_node(option_type, scene_on_editor)
	
	
