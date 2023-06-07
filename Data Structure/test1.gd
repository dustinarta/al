@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var table = DS.Table.new(["nama", "umur", "waktu"], ["string", "number", "datetime"])
	table.insert(["nama", "waktu", "umur"], ["dustin", "now()", 19])
	print(table.select())
#	print(int("123"))
