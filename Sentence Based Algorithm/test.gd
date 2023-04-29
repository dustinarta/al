@tool
extends EditorScript


func _run():
#	print(English._has_init)
	English.init(English.path)
#	print(English._has_init)
	print("ok")
	SBA.init()
#	SBA.dont_execute = true
	print("ok")
	
#	print(SBA._instance_properties_values("man"))
	
#	SBA.push("lynda melinda is a woman")
	SBA.push("ricco and leon is a man")
#	SBA.push("he run")
#	SBA.push("ricco and leon is a man")
#	SBA.push("man")
	print(SBA.sentences[-1].subject.type)
#	print(SBA.Noun.ENUM.none)
#	print(SBA.Noun.Type.keys()[SBA.sentences[-1].subject.type])
#	print("ok")
#	SBA.push("andy is a man")
#	print("SBA ok")
	SBA.push("if he is a man, he run")
#	SBA.push("what ricco do")
#	SBA.push("man is woman")
#	SBA.push("he is woman")
#	print("SBA.sentences ", SBA.sentences)
#	print(SBA.find_class_by_name("man"))
#	print(SBA.create_variable())
#	SBA.push("who ricco is")
#	SBA.push("who is lynda melinda")
#	SBA.push("andy is a man")
#	SBA.push("andy run")
#	SBA.push("andy run")
	SBA.push("what ricco do")
#	SBA.push("to you")
#	SBA.push("push the table to move it")
#	SBA.push("andy is a man")
#	SBA.push("andy always sleep quickly yesterday")
#	SBA.push("who is andy")
	
	English._has_init = false
	SBA._has_init = false
