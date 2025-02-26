extends Control
# This script contains session creation logic

# Path to networking menu UI module
@export_file("*.tscn") var networking_menu_path : String
@onready var networking_menu : PackedScene = load(networking_menu_path)

# select appropriate node via the editor, gets user input
@export_node_path("Label") var logger_path : NodePath
@export_node_path("LineEdit") var address_path : NodePath
@export_node_path("SpinBox") var port_path : NodePath
@export_node_path("OptionButton") var schema_path : NodePath

# used to provide feedback to the user
@onready var logging : Label = get_node(logger_path)

# used to change configuration of the client
@onready var address_input : LineEdit = get_node(address_path)
@onready var port_input : SpinBox = get_node(port_path)
@onready var schema_input : OptionButton = get_node(schema_path)


func _on_create_session_pressed() -> void:
	# extract client config from ui
	var address = address_input.text
	var port = int(port_input.get_line_edit().text)
	var schema = schema_input.text
	
	logging.text = "Creating client.\n"
	var client = Nakama.create_client("defaultkey", address, port, schema)
	
	logging.text = logging.text + "Attempting session creation...\n"
	var session = await client.authenticate_device_async(OS.get_unique_id())
	
	if session.is_exception():
		logging.text = logging.text + "ERROR: " + str(session.get_exception().message)
		return
	
	# save the client config
	Networking.client = client
	# save the session token
	Networking.session = session
	
	# load the networking menu UI module into the scene tree
	self.get_parent().add_child(networking_menu.instantiate())
	
	# remove the current session creation UI
	self.queue_free()
	#logging.text = logging.text + "Session created!\n" + "Attempting socket creation...\n"
	#var socket = Nakama.create_socket_from(client)
	#
	#logging.text = logging.text + "Socket created!\n" + "Attempting socket connection...\n"
	#socket.connect_async(session)
	
