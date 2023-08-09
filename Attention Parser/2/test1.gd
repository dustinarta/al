@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var ap = AP2.new()
	ap.load("res://Attention Parser/2/data.json")
	var res
#	res = ap.read("i have a dog")
	res = ap.read("the thinker is a good man")
	print(res)
#	ap.Words["the"]["thinker"]
#	ap.learn(
#		"i have a dog",
#		"P_ VA JA NC"
#	)
#	ap.learn(
#		"the thinker is a good man",
#		"NP NP VA JA J_ NC"
#	)
#	ap.save("res://Attention Parser/2/data.json")
