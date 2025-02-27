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

	logging.text = "Attempting login...\n"

	# grab client
	var client = Networking.client

	# make sure the user has a working client
	if !await Networking.is_client_valid(client):
		logging.text = logging.text + "Your client is not valid.\n" + "Create a new client.\n"
		return

	# ask nakama for a session token
	var session = await client.authenticate_email_async(email, password, null, false, null)

	# catch exception and inform the user
	if session.is_exception():
		logging.text = logging.text + "ERROR: " + str(session.get_exception().message)
		return

	# make sure the session is valid
	if !Networking.is_session_valid(session):
		logging.text = logging.text + "Failed to create sesion.\n"

	# save the session token
	Networking.session = session

	_on_go_to_network_menu_pressed()

func _on_create_account_pressed() -> void:
	# extract client config from ui
	var email = email_input.text
	var password = password_input.text

	logging.text = "Attempting account creation...\n"

	# grab client
	var client = Networking.client

	# make sure the user has a working client
	if !await Networking.is_client_valid(client):
		logging.text = logging.text + "Your client is not valid.\n" + "Create a new client.\n"
		return

	# ask nakama for a session token
	var session = await client.authenticate_email_async(email, password, null, true, null)

	# catch exception and inform the user
	if session.is_exception():
		logging.text = logging.text + "ERROR: " + str(session.get_exception().message)
		return
	
	if session.created:
		logging.text = logging.text + "Account created!"
		return
		
	logging.text = logging.text + "Account already exits."
	
func _on_go_to_network_menu_pressed() -> void:
	# load the networking menu UI module into the scene tree
	self.get_parent().add_child(networking_menu.instantiate())

	# remove the current session creation UI
	self.queue_free()
