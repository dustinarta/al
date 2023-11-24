extends RefCounted
class_name PackedThread

var threads:Array[Thread]
var packedresult:Array

func _init():
	pass

func start_on_method(methods:Array[Callable], priority:Thread.Priority = 1):
	var worker = methods.size()
	
	packedresult.resize(worker)
	threads.resize(worker)
	for i in range(worker):
		var thread = Thread.new()
		thread.start(methods[i], priority)
		threads[i] = thread
	return OK

func wait_to_finish():
	for i in range(threads.size()):
		packedresult[i] = threads[i].wait_to_finish()
	return packedresult

func is_all_alive():
	for thread in threads:
		if thread.is_alive():
			continue
		return false
	return true

func is_some_alive():
	for thread in threads:
		if thread.is_alive():
			return true
	return false

func is_all_started():
	for thread in threads:
		if thread.is_started():
			continue
		return false
	return true

func is_some_started():
	for thread in threads:
		if thread.is_started():
			return true
	return false

