tool
extends EditorScript

var test_sentence = [
	"i have a car",
	"if today is sunny, then i go to work"
]

func _run():
	var s = "He is: running every morning"
	
#	print(English.get_method_list())
	
	En.init()
	
	print(En.read(test_sentence[1]))
#	var a = En.PRONOUN
#	var b = En.NOUN
#	print(En.PRONOUN == En.PRONOUN)
