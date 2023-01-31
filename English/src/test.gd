tool
extends EditorScript

var test_sentence = [
	"i have a his",
	"his friend is pushing her",
	"i have a very big car",
	"he slowly run",
	"he always run very slowly",
	"a big black car at city",
	"very big car has a big wheels",
	"they slowly push the cart",
	"i sleep if today is sunny"
]

func _run():
	var s = "He is running every morning"
	
	English.init()
#	English.read(test_sentence[5])
	print(English.read(test_sentence[5]))
	
