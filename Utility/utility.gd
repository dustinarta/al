extends Object
class_name Utiliy

"""
Class for utility
"""

static func timeout_ms(callable:Callable, msec:int):
	var thread = Thread.new()
#	var function = Callable(Utiliy._timeout_ms).bind(callable, msec)#.bind(callable).bind(msec)
	var function = Callable(Utiliy, "_timeout_ms").bindv([callable, msec])
	print(function.is_valid())
	thread.start(function)
	print("no error")
	return thread

static func _timeout_ms(callable:Callable, msec:int):
	OS.delay_msec(msec)
	callable.call()

static func timeout_us(callable:Callable, usec:int):
	var thread = Thread.new()
	var function = Callable(_timeout_us)
	function.bind(callable, usec)
	thread.start(function)
	return thread

static func _timeout_us(callable:Callable, usec:int):
	OS.delay_usec(usec)
	callable.call()
