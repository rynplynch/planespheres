extends Control

# ui modules we add and remove from the tree
@export_file("*.tscn") var networking_menu_path : String
@onready var networking_menu : PackedScene = load(networking_menu_path)

# root node that UI module scenes are added to
@export_node_path("Node") var root_path : NodePath
@onready var root_node : Node = get_node(root_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# show the networking menu when the player first load the scene	
	root_node.add_child(networking_menu.instantiate())
