tool
extends EditorScript


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _run():
#	var gd = GDScript.new()
#	gd.set_source_code("func _init():\n\tprint(\"ooomaga\")\nfunc blyat():\n\tprint(\"ooomaga\")")
#	gd.reload()
#
#	var node = Reference.new()
#	node.set_script(gd)
#	node.blyat()

	var script_source = \
	"""
extends Resource

signal run

export var array:Array
export var num:int setget setnum, getnum

func _init():
	print("init called")

func _ready():
	print("ready")

func eval():
	return 2
	
func setnum(value):
	print("amongus")
	num = value * 7
	
func getnum():
	return num / 8
"""
#	extends Resource\n\nexport var array:Array\n\nfunc eval():\n\treturn 2
	var script = GDScript.new()
	script.set_source_code(script_source)
	print(script.reload()) #ok
	print(script.source_code)
	
#	///////////////////////////////////
	var obj = Reference.new()
	obj.set_script(script as Reference)
#	print(obj.has_method("eval")) #true
#	print(obj.has_signal("run")) #true
#	obj.connect("run", obj, "_init")
#	obj.emit_signal("run") #error
#	print(obj.array) #[]
#	print(obj.eval()) #error
#	////////////////////////////////////
	
	obj.num = 10
	obj.num = 90
	print(obj.num)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
