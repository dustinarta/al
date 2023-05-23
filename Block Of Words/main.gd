extends Control

@onready var blocks = $"all container/blocks"
var blockresource:PackedScene = preload("res://Block Of Words/block.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var thread:Thread = Thread.new()
	thread.start(run)

func run():
	var block = blockresource.instantiate()
	blocks.add_child(block)
	block.word = "omaga"
	OS.delay_msec(2000)
	var block1 = blockresource.instantiate()
	var block2 = blockresource.instantiate()
	block.add_new_child(block1, 1)
#	block1.parent = block
	print("child1 after")
	OS.delay_msec(2000)
	block1.add_new_child(block2, 1)
	print("child2 after")
	block1.word = "block1"
	block2.word = "block2"
	block.panel.size.x += block._container.get_child(1).size.x + 1000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
