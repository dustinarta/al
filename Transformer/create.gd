@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	Transformer.create(
		"res://Transformer/test memory.json", 8,
		[
			"#EOS", ",", "i", "have", "a", "dog"
		],
		[
			"#SOS", "#EOS", "#CE", "#CS", "NN", "PN", "VB", "AJ", "AV", "PS", "CE", "CS", "IJ"
		]
	)
	print("done")
