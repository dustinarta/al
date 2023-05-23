@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	BOW.init()
	var result = BOW.push("the big cat is running")
	print(result.print(0, true))
	print(result.be_string())
	
#	var block = BOW.Block.new("oomaga")
#	block.add_child(BOW.Block.new("obamna")).add_child(BOW.Block.new("suuui"))
#	block.add_child(BOW.Block.new("obamna"))
#	block.add_child(BOW.Block.new("obamna"))
#
#	print(block.print())
