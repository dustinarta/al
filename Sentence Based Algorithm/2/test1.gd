@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	English.init(English.path)
	var result = English.read("i have a car")
	var sen = SBA2.SentenceObject.new().init(result)
	print(result)
