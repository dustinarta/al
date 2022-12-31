tool
extends EditorScript

func _run():
	var ts = ThreadServer.new()
	
	for id in range(10):
		ts.push(self, "function", randi())
	
	var past = Time.get_ticks_msec()
	print(ts.wait_all_to_finish())
	print("Time spend " + str(Time.get_ticks_msec() - past))
	
func function(arg)->int:
	arg %= 10000
	OS.delay_msec(arg)
	return arg
