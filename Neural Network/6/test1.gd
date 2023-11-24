@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var nn = NN6.new()
	nn.init({
		"input_count": 2,
		"layers": [3, 4],
		"biassed": true
	})
	var result
#	result = nn.forward_pfa([0.2, 0.3])
	result = nn.forward_apfa(
		[
			[0.2, 0.3],[0.1, -0.2]
		]
	)
	print(result)
