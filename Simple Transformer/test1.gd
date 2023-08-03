@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var st = SimpleTransformer.new()
	st.load("res://Simple Transformer/test memory.json")
	var res
	res = st.forward("i have a dog")
#	res = st.backward("i", "P_")
	print(res)
#	st.save("res://Simple Transformer/test memory.json")
