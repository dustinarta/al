@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var array1 = []
	array1.resize(100000)
	array1.fill([1, 2, 3])
	var array2 = []
	array2.resize(100000)
	array2.fill([1, 2, 3])
	var start
	
	start = Time.get_ticks_msec()
	array1.append_array(array2)
	print("time elapsed ", float(Time.get_ticks_msec()-start)/1000)
