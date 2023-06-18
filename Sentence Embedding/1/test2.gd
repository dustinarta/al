@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sem = SEM.new()
	sem.load("res://Sentence Embedding/1/model1.json")
	var res = sem.push_to_id("kamu sudah mandi", 4)
	print(sem.wordid_to_sentence(res))
	sem.train("kamu sudah mandi", "aku belum mandi")
#	sem.train("siapa namamu", "namaku manusia")
#	sem.save("res://Sentence Embedding/1/model1.json")
	res = sem.push_to_id("kamu sudah mandi")
	print(sem.wordid_to_sentence(res))
#	res = sem.push_to_id("siapa namamu")
#	print(sem.wordid_to_sentence(res))
	print(sem.keys)
