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


func _on_create_client_pressed() -> void:
	# extract client config from ui
	var address = address_input.text
	var port = int(port_input.get_line_edit().text)
	var schema = schema_input.text
	
	# send user feedback
	logging.text = "Creating client.\n"
	# create the client
	var client = Nakama.create_client("defaultkey", address, port, schema)
	
	# use Networking singletons helper function to test client
	if  !await Networking.is_client_valid(client):
		# let user know their client doesn't work
		logging.text = logging.text + "Client failed to connect to server.\n"
		# give them troubleshooting info
		logging.text = logging.text + "It's possible your settings are bad or the server is down\n"
		# break from the function
		return

	# save the client config
	Networking.client = client
	
	_on_go_to_network_menu_pressed()

func _on_go_to_network_menu_pressed() -> void:
	# load the networking menu UI module into the scene tree
	self.get_parent().add_child(networking_menu.instantiate())
	
	# remove the current client creation UI
	self.queue_free()
