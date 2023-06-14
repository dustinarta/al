@tool
extends EditorScript

"""
Multy thread is faster
"""

var array:Array = []
var size = 10000000

func _run():
	
	array.resize(size)
	var start:float
	
	start = Time.get_ticks_msec()
	_t()
	print(array.all(is_one))
	print("time elapsed ", float(Time.get_ticks_msec() - start)/1000)
	
	array.fill(0)
	
	start = Time.get_ticks_msec()
	var thread1 = Thread.new()
	thread1.start(_t1)
	var thread2 = Thread.new()
	thread2.start(_t2)
	thread1.wait_to_finish()
	thread2.wait_to_finish()
	print(array.all(is_one))
	print("time elapsed ", float(Time.get_ticks_msec() - start)/1000)

	array.fill(0)
	
	start = Time.get_ticks_msec()
	var thread21 = Thread.new()
	thread21.start(_t21)
	var thread22 = Thread.new()
	thread22.start(_t22)
	var thread23 = Thread.new()
	thread23.start(_t23)
	var thread24 = Thread.new()
	thread24.start(_t24)
	thread21.wait_to_finish()
	thread22.wait_to_finish()
	thread23.wait_to_finish()
	thread24.wait_to_finish()
	print(array.all(is_one))
	print("time elapsed ", float(Time.get_ticks_msec() - start)/1000)


func _t():
	for i in range(size):
		array[i] = 1

func _t1():
	for i in range(0, size/2):
		array[i] = 1

func _t2():
	for i in range(size/2, size):
		array[i] = 1

func _t21():
	for i in range(0, size/4):
		array[i] = 1

func _t22():
	for i in range(size/4, size/2):
		array[i] = 1

func _t23():
	for i in range(size/2, size/2 + size/4):
		array[i] = 1

func _t24():
	for i in range(size/2 + size/4, size):
		array[i] = 1

func is_one(number):
	if number == 1:
		return true
	else:
		false
