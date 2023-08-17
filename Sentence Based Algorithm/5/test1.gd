@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sba = SBA5.new()
	var ap = AP2.new()
	var res1
	var res2
	ap.load("res://Attention Parser/2/data.json")
	sba.ap = ap
	var sentence = "the dog, frog, and big cat"
#	res = ap.read_s("the big dog")
	res1 = ap.parse_phrase_s(sentence)
	res2 = ap.guess_phrase(res1)
	res1.apply(res2)
	print(res1)
	res1 = sba.read(res1)
	res1 = JSON.stringify(res1, "\t", false)
	
	print(res1)
