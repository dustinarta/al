@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	Transformer.create(
		"res://Transformer/test memory.json", 8, 
		{
			"i" : 1,
			"have" : 2,
			"a" : 3,
			"dog" : 4
		}
	)
	print("done")
