@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var sba = SBA4.new()
	sba.read_s("the dog and the cat")
