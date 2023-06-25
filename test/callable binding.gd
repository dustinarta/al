@tool
extends EditorScript

"""

"""

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var callable
	
	callable = Callable(fun)
	callable = callable.bind(1)
	callable.call(2)
	
	"Output: 2 1"
	
	callable = Callable(fun)
	callable = callable.bind(1).bind(2)
	callable.call()
	
	"Output: 2 1"
	
	callable = Callable(fun)
	callable = callable.bindv([2, 1])
	callable.call()
	
	"Output: 2 1"
	

func fun(arg1, arg2):
	print(arg1, " ", arg2)
