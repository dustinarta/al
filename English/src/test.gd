tool
extends EditorScript

var test_sentence = [
	"i have a car",
	"his friend is pushing his",
	"if today is sunny, i go to work"
]

func _run():
	var s = "He is running every morning"
	
	English.init()
	
	print(English.read(test_sentence[1]))
	
