extends Node

# Get reference to server script, creating an instance of it
@onready var server = preload("res://scripts/server.gd").new()

func _ready() -> void:
	# add it as a child to our node
	self.add_child(server)
