extends Control

# select appropriate node via the editor
@export_node_path("Label") var logger_path : NodePath
@export_node_path("Tree") var match_list_tree_path : NodePath
@export_file("*.tscn") var networking_menu_path : String

# networking menu to swap out our match menu UI module
@onready var networking_menu : PackedScene = load(networking_menu_path)

# used to provide feedback to the user
@onready var logger : Label = get_node(logger_path)

# used to hold matches data
@onready var match_list : Array = []
# used to display certain data from match list
@onready var match_list_tree : Tree = get_node(match_list_tree_path)

func _ready() -> void:
	pass

func _on_create_match_pressed() -> void:
	Rpc.create_match(logger)

func _on_refresh_matches_pressed() -> void:
	pass # Replace with function body.

func _on_return_to_networking_pressed() -> void:
	# load the networking menu UI model into the scene tree
	get_parent().add_child(networking_menu.instantiate())

	# remove the match menu UI from the scene tree
	self.queue_free()
