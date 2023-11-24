@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	
	print(
		Matrix.new().init(2, 9).self_resquare_diagonal(1.0)
	)
