extends Control

# select appropriate node via the editor
@export_node_path("Label") var logger_path : NodePath
@export_node_path("CheckBox") var client_status_path : NodePath
@export_node_path("CheckBox") var session_status_path : NodePath
@export_node_path("CheckBox") var socket_status_path : NodePath 
@export_node_path("Button") var client_button_path : NodePath 
@export_node_path("Button") var session_button_path : NodePath 
@export_node_path("Button") var socket_button_path : NodePath 
@export_file("*.tscn") var create_client_path : String
@export_file("*.tscn") var create_session_path : String
@export_file("*.tscn") var main_menu_path : String

# main menu UI scene to swap out networking UI scene
@onready var main_menu : PackedScene = load(main_menu_path)

# module UI elements we load in to alter Networking singleton
@onready var create_client : PackedScene = load(create_client_path)
@onready var create_session : PackedScene = load(create_session_path)

# used to provide feedback to the user
@onready var logger : Label = get_node(logger_path)

# used to display network element statuses
@onready var client_status : CheckBox = get_node(client_status_path)
@onready var session_status : CheckBox = get_node(session_status_path)
@onready var socket_status : CheckBox = get_node(socket_status_path)

# used to show buttons as the player needs the
@onready var client_button : Button = get_node(client_button_path)
@onready var session_button : Button = get_node(session_button_path)
@onready var socket_button : Button = get_node(socket_button_path)

func _ready() -> void:
	# start these button as hidden
	client_button.hide()
	session_button.hide()
	socket_button.hide()

	if await update_client_status() \
	&& update_session_status():
	#&& update_socket_status():
		pass
	
	#logging.text = logging.text + "Session created!\n" + "Attempting socket creation...\n"
	#var socket = Nakama.create_socket_from(client)
	#
	#logging.text = logging.text + "Socket created!\n" + "Attempting socket connection...\n"
	#socket.connect_async(session)

# Check the status of the Network.client and update UI elements
func update_client_status() -> bool:
	# grab users client object
	var client : NakamaClient = Networking.client
	
	# use helper function to test client
	if await Networking.is_client_valid(client):
		# toggle the check box in the affirmative
		client_status.set_pressed_no_signal(true)
		return true
	
	# toggle check box in the negative
	client_status.set_pressed_no_signal(false)
	# give the user feedback
	logger.text = "You must configure a new client."
	
	# Show only the configure client button
	client_button.show()
	# Make sure the others are hidden
	session_button.hide()
	socket_button.hide()
	
	return false
	
# Check the status of the Network.session and update UI elements
func update_session_status() -> bool:
	# if the player has a valid session
	if Networking.is_session_valid(Networking.session):
		# toggle the check box in the affirmative
		session_status.set_pressed_no_signal(true)
		# give the player further feedback
		session_status.text = "Your session is valid!"
		return true
	
	session_status.set_pressed_no_signal(false)
	session_status.text = "You don't have a valid session!"
	logger.text = "You must create a new session"	
	return false

# Check the status of the Network.socket and update UI elements
func update_socket_status():
	# socket checkbox is unhidden
	socket_status.show()
	
	# if the player has a valid session
	if Networking.socket && Networking.socket.is_connected_to_host():
		# toggle the check box in the affirmative
		socket_status.set_pressed_no_signal(true)
		# give the player further feedback
		socket_status.text = "Looks like a socket is available!"
		logger.text = "You may start a new game"	
	else:
		socket_status.set_pressed_no_signal(false)
		socket_status.text = "No available sockets"
		logger.text = "You must create a new socket connection"	


func _on_go_to_session_pressed() -> void:
	# load the create session UI model into the scene tree
	get_parent().add_child(create_session.instantiate())

	# remove the networking menu UI from the scene tree
	self.queue_free()


func _on_configure_client_pressed() -> void:
	# load the create session UI model into the scene tree
	get_parent().add_child(create_client.instantiate())

	# remove the networking menu UI from the scene tree
	self.queue_free()


func _on_return_to_main_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu)
