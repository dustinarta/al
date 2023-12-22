@tool
extends EditorScript

var count:int = 2000

var val:int
# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	val = 0
	var start = Time.get_ticks_usec()
	fun1()
	print(float(Time.get_ticks_usec()-start)/1000000.0)
	start = Time.get_ticks_usec()
	fun2()
	print(float(Time.get_ticks_usec()-start)/1000000.0)


func fun1():
	for i in range(count):
		for k in range(count):
			val += 1

func fun2():
	var val:int
	for i in range(count):
		itteration()

func itteration():
	for k in range(count):
		val += 1

