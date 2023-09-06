@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var program = SBA5_ProgramHigh.new()
	program.init()
	
#	program.parse_s(
#		"declare name"
#	)
	print(
		program.parse_s(
#			"declare list as Array to [1, 2, 3, 4];\n" +
#			"set list at 0 to 90;"
#			"if x equal 10:\n" + 
#			"set x to 10.\n" + 
#			"return x."
#			"what x add 2 mul 3."
#			"set x to what 2 add 3."
			"on self call start."
		)
	)
#	print(JSON.parse_string("null"))
