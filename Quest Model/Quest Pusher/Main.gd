extends Control

onready var popup_open = $Panel/Container/Menu/btnOpen/openDialog
onready var popup_save = $Panel/Container/Menu/btnSaveas/saveasDialog

var my_json:Dictionary


func _ready():
	OS.set_window_title("(*)")
	OS.set_window_size(Vector2(600, 400))
#	_on_openDialog_file_selected("res://src/dataset.json")
#	data_container.get_parent().emit_signal("emit_json", my_json)




func _on_btnOpen_pressed():
	popup_open.popup()

func _on_btnSave_pressed():
	pass # Replace with function body.


func _on_btnSaveas_pressed():
	popup_save.popup()
