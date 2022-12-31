extends Node


var script_source = \
	"""
extends Reference

signal run

export var array:Array
export var num:int setget setnum, getnum

func _init():
	print("init called")

func _ready():
	print("ready")

func eval():
	print("called eval")
	return 2
	
func setnum(value):
	print("amongus")
	num = value * 7
	
func getnum():
	return num / 8
"""

# Called when the node enters the scene tree for the first time.
func _ready():
	var script = GDScript.new()
	script.set_source_code(script_source)
	print(script.reload()) #ok
	print(script.source_code)
	
	var obj = Reference.new()
	obj.set_script(script as Reference)
	obj.eval()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
