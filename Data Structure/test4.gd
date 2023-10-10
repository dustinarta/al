@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var ll1 = DS.LinkedList.new(1)
	var ll2 = DS.LinkedList.new(2)
	var ll3 = DS.LinkedList.new(3)
	var ll4 = DS.LinkedList.new(4)
	ll1.link("next", ll2)
	ll1.link_between("next", ll3, "prev")
	print(
		ll1.traverse()
	)
	print(
		ll2.traverse()
	)
	print(
		ll3.traverse()
	)
	print(DS.E)
	
	
