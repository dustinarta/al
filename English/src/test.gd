tool
extends EditorScript

var test_sentence = [
	"i have a his car",
	"his friend is pushing his",
	"i have a big good car",
	"they slowly push the cart",
	"i go to work if today is sunny"
]

func _run():
	var s = "He is running every morning"
	
	English.init()
	
	print(English.read(test_sentence[2]))
	
