extends Control
# This script contains session creation logic

# Path to networking menu UI module
@export_file("*.tscn") var networking_menu_path : String
@onready var networking_menu : PackedScene = load(networking_menu_path)

# select appropriate node via the editor, gets user input
@export_node_path("Label") var logger_path : NodePath
@export_node_path("LineEdit") var email_path : NodePath
@export_node_path("LineEdit") var password_path : NodePath

# used to provide feedback to the user
@onready var logging : Label = get_node(logger_path)

# credentials the client will use to grab a session token
@onready var email_input : LineEdit = get_node(email_path)
@onready var password_input : LineEdit = get_node(password_path)


func _on_create_session_pressed() -> void:
	# extract client config from ui
	var email = email_input.text
	var password = password_input.text
	
	# create session
	var session = await Networking.request_session_token(Networking._client, email, password, false ,logging)
	
	# if session is null creation failed
	if !session:
		return 
	
	_on_go_to_network_menu_pressed()

func _on_create_account_pressed() -> void:
	# extract client config from ui
	var email = email_input.text
	var password = password_input.text

	# grab client
	var client = Networking._client
	
	# create account
	Networking.request_session_token(client, email, password, true, logging)
	
func _on_go_to_network_menu_pressed() -> void:
	# load the networking menu UI module into the scene tree
	self.get_parent().add_child(networking_menu.instantiate())

	# remove the current session creation UI
	self.queue_free()
