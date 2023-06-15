extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var sem = SEM.new()
	sem.load("res://Sentence Embedding/1/model1.json")
	sem.push("aku belum mandi")
	print("goodbye")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
