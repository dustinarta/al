@tool
extends EditorScript

"""
For loop is faster than while loop
"""

var array:Array = []

func _run():
	var size = 1000000
	array.resize(size)
	var start:float
	start = Time.get_ticks_msec()
	fun_for(0, size)
	print("time elapsed ", float(Time.get_ticks_msec()-start)/1000)
	
	start = Time.get_ticks_msec()
	fun_while(0, size)
	print("time elapsed ", float(Time.get_ticks_msec()-start)/1000)


func fun_for(from, to):
	for i in range(from, to):
		array[i] = 1

func fun_while(i, to):
	while i < to:
		array[i] = 1
		i += 1
