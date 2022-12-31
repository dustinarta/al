extends HBoxContainer

export var key:String = "null"
export var id:int = 0
signal set_up

onready var Key = $key
onready var Id = $id
onready var Delete = $delete
onready var DataControl = self.get_parent().get_parent()

func _ready():
	Key.text = key
	Id.text = str(id)

func set_up(data = null):
	if typeof(data) == TYPE_ARRAY:
		Key.text = data[0]
		Id.text = str(data[1])
		key = data[0]
		id = data[1]
	else:
		printerr("error at set_up, the data was " + str(data))

func _on_delete_pressed():
	DataControl.emit_signal("delete_child", self)
