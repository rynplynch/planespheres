extends Control

# select appropriate node via the editor
@export_node_path("Label") var logger_path : NodePath
@export_node_path("CheckBox") var session_status_path : NodePath
@export_node_path("CheckBox") var socket_status_path : NodePath 
@export_file("*.tscn") var create_session_path : String
@onready var create_session : PackedScene = load(create_session_path)

# used to provide feedback to the user
@onready var logger : Label = get_node(logger_path)

# used to display network element statuses
@onready var session_status : CheckBox = get_node(session_status_path)
@onready var socket_status : CheckBox = get_node(socket_status_path)


func _ready() -> void:
	# don't show the socket checkbox until our session is valid
	socket_status.hide()
	
	# if our session is ready
	if update_session_status():
		# also check if we have a socket free
		update_socket_status()	
	
	#logging.text = logging.text + "Session created!\n" + "Attempting socket creation...\n"
	#var socket = Nakama.create_socket_from(client)
	#
	#logging.text = logging.text + "Socket created!\n" + "Attempting socket connection...\n"
	#socket.connect_async(session)
	
# Check the status of the Network.session and update UI elements
func update_session_status() -> bool:
	# if the player has a valid session
	if Networking.session && Networking.session.is_valid():
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

