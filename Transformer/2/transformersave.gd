@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var transformer:Transformer4 = Transformer4.new()
	transformer.init(64, 1, 4, 4)
	transformer.wem.append_word("<p> 0 1 2 3 4 5 6 7 8 9".split(" "))
	transformer.save("res://Transformer/4/datatest.json")
