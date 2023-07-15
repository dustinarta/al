@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var data = [0.5, 0.3, 0.2, 0.2, 0.1, 1]
	print(DS.minmax_normalization(data))
