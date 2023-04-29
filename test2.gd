@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var a = [1, 2, 3, 4, 5]
	a.sort()
	print(a)
	var pos = a.bsearch_custom(2, custom_seacrh, false)
	print(a[pos])
	
func custom_seacrh(v1, v2):
	if v1 != v2:
		return false
	else:
		return true
