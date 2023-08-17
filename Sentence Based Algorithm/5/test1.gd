@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sba = SBA5.new()
	var ap = AP2.new()
	var res
	ap.load("res://Attention Parser/2/data.json")
	sba.ap = ap
	
#	res = ap.read_s("the big dog")
#	res = ap.parse_phrase_s("the big dog")
	
	res = sba.read_s("the big dog")
	res = JSON.stringify(res, "\t", false)
	
	print(res)
