extends Control

@onready var line = $VBoxContainer/line
@onready var answer = $VBoxContainer/answer

# Called when the node enters the scene tree for the first time.
func _ready():
	SBA.init()
	print(SBA.Classes)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var jawaban = SBA.push(line.text)
	answer.text = jawaban
	SBA.save()
