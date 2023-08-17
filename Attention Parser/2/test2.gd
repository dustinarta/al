@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var ap = AP2.new()
	ap.load("res://Attention Parser/2/data.json")
	
	var res
	
#	res = ap.read("he is a good boy")
#	res = ap.parse_phrase_s("she is a good girl")
#	res = ap.parse_phrase_s("she quickly run in")
	res = ap.parse_phrase_s("you and me is running")
#	print(res)
#	res = ap.guess_phrase(res)
	res = res.phrases[3].find_type_all("VA")
	print(res)
#	ap.save("res://Attention Parser/2/data.json")
