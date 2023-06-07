@tool
extends EditorScript

var bowal = preload("res://Block Of Words/bow_al.gd").new()

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	BOW.init()
	
	bowal.init(bowal.path)
	print(bowal.code)
