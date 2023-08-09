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
	res = st.backward("i have a dog", "P_ V_ J_ NC")
#	return
#	print(res)
	for i in range(100):
		res = st.backward("i have a dog", "P_ V_ J_ NC")
		if res == null:
			printerr("error")
			break
#		res = st.backward("i have", "P_ V_")
#		if res == null:
#			printerr("error")
#			break
	
	res = st.forward("i have")
	print(res)
	res = st.forward("i have a dog")
	print(res)
#	print(st.Output_vector)
#	print( st.generate_output(["P_", "PP", ",E"]) )
	st.save("res://Simple Transformer/test memory.json")
