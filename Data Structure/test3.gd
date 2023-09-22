@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var collection = DS.Collection.new()
	collection.set_has_function(
		Callable(self, "has_function")
	)
	var data = [
		[1, 2, 3],
		[2, 3, 4]
	]
	collection.fill(data)
	var res = collection.select_and([1, 2])
	print(res.data)

func has_function(data, selection):
	if data.has(selection):
		return true


