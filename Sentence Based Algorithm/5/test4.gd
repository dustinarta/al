@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var program = load("res://Sentence Based Algorithm/5/script.gd").new()
	var ap:AP2_2 = AP2_2.new()
	ap.init_ap()
	var sentence
#	sentence = ap.read_s2("andy lukito has a dog")
#	sentence = ap.read_s2("alex has a dog")
	sentence = ap.read_s2("alex sleep")
#	sentence = ap.read_s2("what is alex has")
	program.start()
	program.input(sentence)
#	program.finish()
	printerr("unfinish")
	
