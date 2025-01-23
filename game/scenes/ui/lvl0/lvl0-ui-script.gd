extends Node

# button to trigger switch to single player scene

func _on_player_property_list_changed() -> void:
	print("DSPOS")
	$Control/MarginContainer/HBoxContainer/PlayerPosition.bind_text(self, "Hey!")
