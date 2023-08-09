@tool
extends EditorScript



func _run():
	var ap = AP.new()
	ap.load("res://Attention Parser/data.json")
#	ap.set_word("i", "PP")
	var res
#	res = ap.read("i")
#	print(res)
#	ap.set_name(["The", "Great", "Alexander"])
#	ap.set_name(["The", "Thinker"])
#	print(ap.Names)
	ap.learn(
		"The Thinker is a smart man like The Great Alexander",
		"NP NP VA J_ J_ NC V_ NP NP NP"
	)
	ap.save("res://Attention Parser/data.json")
