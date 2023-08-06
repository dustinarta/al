@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var st = SimpleTransformer.new()
	st.load("res://Simple Transformer/test memory.json")
	var res
#	res = st.forward("i have")
#	print(res)
#	return
	res = st.backward("i have", "P_ V_")
	return
#	print(res)
#	for i in range(10):
#		res = st.backward("i", "P_")
	
	res = st.forward("i have")
	print(res)
#	print(st.Output_vector)
#	print( st.generate_output(["P_", "PP", ",E"]) )
#	st.save("res://Simple Transformer/test memory.json")
