extends GraphNode


# Called when the node enters the scene tree for the first time.
func _ready():
	title = "Default"
	for i in range(2):
		self.set_slot(i, true, 0, Color(1, 1, 1, 1), true, 0, Color(1, 1, 1, 1))
	self.set_slot(0, true, 0, Color(1, 1, 1, 1), true, 0, Color(1, 1, 1, 1))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
