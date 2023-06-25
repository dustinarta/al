extends Control

@onready var input = $VBox/input
@onready var output = $VBox/output

var sem:SEM

func _ready():
	sem = SEM.new()
	sem.load("res://Sentence Embedding/1/model2.json")
#	sem.push("kamu sudah mandi")
	print("goodbye")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("\a")


func _on_push_pressed():
	output.text = sem.push(input.text)
