@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sem = SEM.new()
	sem.load("res://Sentence Embedding/1/model1.json")
	
	print(sem.keys)
