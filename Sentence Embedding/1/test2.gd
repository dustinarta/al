@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sem = SEM.new()
	sem.load("res://Sentence Embedding/1/model1.json")
	var res = sem.push_to_id("aku belum mandi")
	sem.train("kamu sudah mandi", "aku belum mandi")
#	print(sem.wordid_to_sentence(res))
	print(sem.keys)
