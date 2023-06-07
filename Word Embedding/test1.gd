@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var wem = WEM.new()
#	wem.load()
	wem.push("aku belum mandi")
	print(wem.keys)
