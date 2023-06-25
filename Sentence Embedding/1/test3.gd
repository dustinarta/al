@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sem = SEM.new()
	sem.load("res://Sentence Embedding/1/model1.json")
	var res
	res = sem.push_to_id("kamu sudah mandi", 4)
	print(sem.wordid_to_sentence(res))
#	sem.train2("kamu sudah mandi", "aku belum mandi")
#	sem.train2("siapa namamu", "namaku manusia")
	var start = Time.get_ticks_msec()
#	sem.train_many3(
#		[
#			"kamu sudah mandi",
#			"siapa namamu"
#		],
#		[
#			"aku belum mandi",
#			"namaku manusia"
#		], 10000
#	)
	print("time elapsed ", float(Time.get_ticks_msec()-start)/1000)
#	sem.save("res://Sentence Embedding/1/model1.json")
	res = sem.push_to_id("kamu sudah mandi")
	print(sem.wordid_to_sentence(res))
	res = sem.push_to_id("siapa namamu")
	print(sem.wordid_to_sentence(res))
	print(sem.keys)
