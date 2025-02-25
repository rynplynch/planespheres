extends Control

# scene swapped to when singleButton pushed
@export_file("*.tscn") var lvl_debug_path
@onready var lvl_debug : PackedScene = load(lvl_debug_path)
@export_file("*.tscn") var networking_path
@onready var networking : PackedScene = load(networking_path)


func _on_single_button_pressed():
	get_tree().change_scene_to_packed(lvl_debug)


func _on_lobby_button_pressed():
	get_tree().change_scene_to_packed(networking)
