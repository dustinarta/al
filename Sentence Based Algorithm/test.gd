@tool
extends EditorScript


func _run():
#	print(English._has_init)
	English.init(English.path)
	SBA.init()
#	print(English._has_init)
#	SBA.dont_execute = true
	
#	print(SBA._instance_properties_values("man"))
	
#	SBA.push("lynda melinda is a woman")
	SBA.push("ricco and leon is a man")
#	SBA.push("he run")
#	SBA.push("ricco and leon is a man")
#	SBA.push("man")
#	print(SBA.Noun.ENUM.none)
#	print(SBA.Noun.Type.keys()[SBA.sentences[-1].subject.type])
#	print("ok")
#	SBA.push("andy is a man")
#	print("SBA ok")
#	SBA.push("if he is a man, he run")
#	print(SBA.Variable[1])
#	print(SBA.Variable[2])
#	SBA.push("what ricco do")
#	SBA.push("man is woman")
#	SBA.push("he is woman")
	SBA.push("London is a city")
#	SBA.push("ricco")
	SBA.push("ricco is in london")
	SBA.push("where is ricco")
#	print(SBA.Variable[SBA.find_variable_by_name("ricco")])
#	SBA.push("who ricco is")
#	print(SBA.Variable[-1])
#	SBA.save()
	
	English._has_init = false
	SBA._has_init = false
