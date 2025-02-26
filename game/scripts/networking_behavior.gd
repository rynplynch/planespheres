extends Node

@export_file("*.tscn") var networking_ui_path
@onready var networking_ui : PackedScene = load(networking_ui_path)


func _ready() -> void:
		# Load main menu UI
	self.add_child(networking_ui.instantiate())
