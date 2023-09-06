@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var program = SBA5_ProgramHigh.new()
	
#	for i in range(20):
#		print(SBA5_Program.generatelabel())
	var first:int = -1
	var key:Dictionary
	var i:int = 0
	while i < 100000:
		var word = SBA5_ProgramHigh.generatelabel()
		if key.has(word):
			if first == -1:
				print("first collision at ", word, " in ", i)
				first = i
			else:
				print("second collision at ", word, " in ", i)
				break
		key[word] = null
		i += 1
	print(program.lines)
