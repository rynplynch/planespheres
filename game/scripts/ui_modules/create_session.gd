extends Control
# This script contains session creation logic

# Path to networking menu UI module
@export_file("*.tscn") var networking_menu_path : String
@onready var networking_menu : PackedScene = load(networking_menu_path)

# select appropriate node via the editor, gets user input
@export_node_path("Label") var logger_path : NodePath

# used to provide feedback to the user
@onready var logging : Label = get_node(logger_path)



func _on_create_session_pressed() -> void:
	# extract client config from ui
	
	
	
	if session.is_exception():
		logging.text = logging.text + "ERROR: " + str(session.get_exception().message)
		return
	
	# save the session token
	Networking.session = session
	
	# load the networking menu UI module into the scene tree
	self.get_parent().add_child(networking_menu.instantiate())
	
	# remove the current session creation UI
	self.queue_free()
