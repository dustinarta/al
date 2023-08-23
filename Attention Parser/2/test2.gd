@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var ap = AP2.new()
	var ap2 = AP2_2.new()
	ap.load("res://Attention Parser/2/data.json")
	ap2.ap = ap
	var res = ap2.read_s("i will be happy if i have a dog in my house")
	print(res)
#	
