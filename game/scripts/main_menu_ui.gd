extends Control

# scene swapped to when singleButton pushed
@export_file("*.tscn") var lvlDebug
@export_file("*.tscn") var clientScene

# button to trigger switch to single player scene
@onready var lvl0_button = $"MarginContainer/VBoxContainer/SingleButton"

func _on_single_button_pressed():
	get_tree().change_scene_to_file(lvlDebug)


func _on_lobby_button_pressed():
	get_tree().change_scene_to_file(clientScene)
