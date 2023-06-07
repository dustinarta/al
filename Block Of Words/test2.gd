@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	BOW.init()

	print(BOW.push("andy is a man"))
	print(BOW.push("andy is worker because he is"))
#	BOW.push("henry is a man")
#	BOW.push("jamal is a man")
	print(BOW.push("who is andy"))
	print(BOW.allsentences)
#	print(result.be_string() + "\"")
#	print(BOW.keys)
#	print(BOW.allsentences.select_or_by_word(["is"]))
	
#	var block = BOW.Block.new("oomaga")
#	block.add_child(BOW.Block.new("obamna")).add_child(BOW.Block.new("suuui"))
#	block.add_child(BOW.Block.new("obamna"))
#	block.add_child(BOW.Block.new("obamna"))
#
#	print(block.print())
