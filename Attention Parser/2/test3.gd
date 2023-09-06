@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var ap = AP2_2.new()
	ap.init_ap()
	var res
	
	res = ap.read_paragraph_s("i have a dog. i have a cat.")
	print(res)
