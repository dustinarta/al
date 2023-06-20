@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sem = SEM.new()
	sem.create(
		[
			"apakah kamu sudah mandi",
			"aku belum mandi",
			"siapa namamu",
			"namaku manusia",
			"dimana rumahmu",
			"rumahku di bontang"
		],
		100
	)
	sem.save("res://Sentence Embedding/1/model1.json")
	print(sem.keys)
