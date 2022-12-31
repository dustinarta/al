extends Reference
class_name ThreadServer

var vault:Array = []

func _init():
	pass

func push(instance: Object, method: String, userdata = null, priority:= 1)->int:
	var t = Thread.new()
	vault.push_back(t)
	return t.start(instance, method, userdata, priority)

func is_all_active()->bool:
	for t in vault:
		if !t.is_active():
			return false
	return true
	
func is_one_active()->bool:
	for t in vault:
		if t.is_active():
			return true
	return false
	
func is_all_alive()->bool:
	for t in vault:
		if !t.is_alive():
			return false
	return true
	
func is_one_alive()->bool:
	for t in vault:
		if t.is_alive():
			return true
	return false

func wait_all_to_finish(wait_delay := 8)->Array:
	var done = false
	var result = []
	var still_running = []
	var count = vault.size()
	result.resize(count)
	still_running.resize(vault.size())
	still_running.fill(true)
	
	while !done:
		for idx in range(count):
			if still_running[idx] == false:
				continue
			elif vault[idx].is_active():
				if vault[idx].is_alive():
					continue
				else:
					result[idx] = vault[idx].wait_to_finish()
					still_running[idx] = false
		OS.delay_msec(wait_delay)
		if !still_running.has(true):
			done = true
	
	return result
