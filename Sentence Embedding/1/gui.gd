extends Control

@onready var input = $VBox/input
@onready var output = $VBox/output

var sem:SEM

func _ready():
	sem = SEM.new()
	sem.load("res://Sentence Embedding/1/model1.json")
	sem.push("aku belum mandi")
	print("goodbye")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_push_pressed():
	output.text = sem.push(input.text)
