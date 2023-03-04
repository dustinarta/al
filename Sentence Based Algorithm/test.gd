tool
extends EditorScript


func _run():
	print(English._has_init)
	English.init(English.path)
	print(English._has_init)
	SBA.init()
	
#	SBA.push("lynda melinda is a woman")
#	SBA.push("andy is a man")
#	SBA.push("who is andy")
	
	SBA.push("andy is a man")
	SBA.push("andy always sleep quickly yesterday")
	SBA.push("who is andy")
	
	English._has_init = false
	SBA._has_init = false
