extends Reference

enum {
	UNION,
	INTERSECTION
}

func _init():
	pass

func operate(A:Array, B:Array, op)->Array:
	var _r:Array = []
	match op:
		UNION:
			_r = A.duplicate(true)
			for item in B:
				if _r.has(item):
					continue
				else:
					_r.push_back(item)
		INTERSECTION:
			for item in A:
				if B.has(item):
					_r.push_back(item)
	return _r
