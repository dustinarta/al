@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sem = SEM.new()
	sem.load("res://Sentence Embedding/1/model2.json")
	var res
#	res = sem.push_to_id("kamu sudah mandi", 4)
#	print(sem.wordid_to_sentence(res))
#	sem.train2("kamu sudah mandi", "aku belum mandi")
#	sem.train2("siapa namamu", "namaku manusia")
	var start = Time.get_ticks_msec()
	sem.train_many3(
		[
			"apakah kamu mau menikah denganku",
			"kamu mau pernikahannya sederhana atau mewah",
			"kalau kita sudah menikah kamu mau punya anak berapa"
		],
		[
			"iya aku mau sayangku cintaku",
			"sesuai kemampuanmu",
			"aku mau punya anak 2"
		], 10000
	)
	print("time elapsed ", float(Time.get_ticks_msec()-start)/1000)
	sem.save("res://Sentence Embedding/1/model2.json")
	res = sem.push_to_id("apakah kamu mau menikah denganku")
	print(sem.wordid_to_sentence(res))
	res = sem.push_to_id("kamu mau pernikahannya sederhana atau mewah")
	print(sem.wordid_to_sentence(res))
	res = sem.push_to_id("kalau kita sudah menikah kamu mau punya anak berapa")
	print(sem.wordid_to_sentence(res))
	print(sem.keys)
