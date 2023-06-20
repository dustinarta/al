@tool
extends EditorScript

"""
Multy thead fill is okay
"""

var array:Array = []
var size = 7863

func _run():
	
	array.resize(size)
	
	var thread1 = Thread.new()
	thread1.start(_t1)
	var thread2 = Thread.new()
	thread2.start(_t2)
	
	thread1.wait_to_finish()
	thread2.wait_to_finish()
	print(array.all(is_one))

func _t1():
	for i in range(0, size/2):
		array[i] = 1

func _t2():
	for i in range(size/2, size):
		array[i] = 1

func is_one(number):
	if number == 1:
		return true
	else:
		false
