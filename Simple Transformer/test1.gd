@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var st = SimpleTransformer.new()
	st.load("res://Simple Transformer/test memory.json")
	st.forward()
