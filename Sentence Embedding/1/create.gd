@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sem = SEM.new()
	sem.create(
		[
			"apakah kamu mau menikah denganku",
			"iya aku mau sayangku cintaku",
			"kamu mau pernikahannya sederhana atau mewah",
			"sesuai kemampuanmu",
			"kalau kita sudah menikah kamu mau punya anak berapa",
			"aku mau punya anak 2"
		],
		100
	)
	sem.save("res://Sentence Embedding/1/model2.json")
	print(sem.keys)
