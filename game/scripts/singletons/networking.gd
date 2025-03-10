extends Node

var _client : NakamaClient;
var _session : NakamaSession;
var _socket : NakamaSocket;
var _socket_connected : bool = false;

# Creation functions
# Attempt client creation
func create_client(address : String, port : int, schema : String, logging : Control) -> NakamaClient:
	# send user feedback
	logging.text = "Creating client.\n"
	# create the client
	var client = Nakama.create_client("defaultkey", address, port, schema)
	
	# use Networking singletons helper function to test client
	if  !await is_client_valid(client):
		# let user know their client doesn't work
		logging.text = logging.text + "Client failed to connect to server.\n"
		# give them troubleshooting info
		logging.text = logging.text + "It's possible your settings are bad or the server is down\n"
		# break from the function
		return null
	
	return client

# either return a valid session token, or create a new account depending on create bool
func request_session_token(client : NakamaClient, email : String, password : String, create : bool ,logging : Control) -> NakamaSession:
	if create:
		logging.text = "Attempting account creation...\n"
	else:
		logging.text = "Attempting login...\n"

	# make sure the user has a working client
	if !await Networking.is_client_valid(client):
		logging.text = logging.text + "Your client is not valid.\n" + "Create a new client.\n"
		return null

	# ask nakama for a session token
	var session = await client.authenticate_email_async(email, password, null, create, null)

	# catch exception and inform the user
	if session.is_exception():
		logging.text = logging.text + "ERROR: " + str(session.get_exception().message)
		return null
	
	# if the call was to create an account
	if create:
		# the account creation was successful
		if session.created:
			logging.text = logging.text + "Account created!"
			return null
		logging.text = logging.text + "Account already exits."
		return null
	
	# make sure the session is valid
	if !is_session_valid(session):
		logging.text = logging.text + "Failed to create sesion.\n"
		return null
	
	logging.text = logging.text + "Session created!\n"
	return session

# create a new socket connection, and register functions to respond to signals
func create_socket(client : NakamaClient, session : NakamaSession, logging : Control) -> NakamaSocket:
	logging.text = "Attempting socket creation\n"
	
	# make sure the user has a working client
	if !await Networking.is_client_valid(client):
		logging.text = logging.text + "Your client is not valid.\n" + "Create a new client.\n"
		return null
	
	# make sure user has valid session
	if !is_session_valid(session):
		logging.text = logging.text + "Your session is not valid.\n" + "Create a new session.\n"
		return null
	
	# create a socket
	var socket = Nakama.create_socket_from(client)
	
	# register functions
	socket.connected.connect(self._on_socket_connected)
	socket.closed.connect(self._on_socket_closed)
	socket.received_error.connect(self._on_socket_error)
	
	logging.text = logging.text + "Attempting socket connection...\n"
	# attempt to create a socket connection
	await socket.connect_async(session)
	
	if _socket_connected:
		logging.text = logging.text + "Socket connection succesful!\n"
		
		# return socket reference to caller
		return socket
	
	logging.test = logging.text + "Socket connection failed.\n"
	return null

# socket functions, respond to socket signals when they are emitted
func _on_socket_connected():
	print("Socket connected\n")
	_socket_connected = true
	
func _on_socket_closed():
	print("Socket closed\n")
	_socket.free()
	_socket_connected = false
	
func _on_socket_error(err):
	print("Socket recieved error: " + str(err) + '\n')
	_on_socket_closed()
	
# Helper functions
# Returns true of the client can reach a Nakama server
func is_client_valid(client : NakamaClient) -> bool:
	# check if client is null
	if !client:
		return false
	
	# attempt to create a test sesion
	var session = await client.authenticate_custom_async("MyIdentifier")

	# only returns true of produced session is valid
	return is_session_valid(session)
	
# Returns true if the session is valid 
func is_session_valid(session : NakamaSession) -> bool:
	# return true if session is not null AND is valid AND is not expired
	return session && session.is_valid() && !session.is_expired()

# Check the status of the Network.client and output logger info
func check_client_status(client : NakamaClient, logger : Control) -> bool:
	# Let the user know we are performing work
	logger.text = "Checking client status...\n"
	
	# use helper function to test client
	if await is_client_valid(client):
		# give the user feedback
		logger.text = "Your client is valid!\n"		
		return true
	
	# give the user feedback
	logger.text = "You must configure a new client.\n"
	return false
	
# Check the status of the Network.session and update UI elements
func check_session_status(session : NakamaSession, logger : Control) -> bool:
	# Let the user know we are performing work
	logger.text = "Checking session status...\n"
	
	# if the player has a valid session
	if is_session_valid(session):
		logger.text = logger.text + "Your session is valid!\n"
		return true
	
	logger.text = logger.text + "You must create a new session.\n"	
	return false

# Check the status of the Network.socket and update UI elements
func check_socket_status(logger : Control) -> bool:
	# if the socket is connected
	if _socket_connected:
		# give the player feedback
		logger.text = "You may start a new game"
		return true
	else:
		logger.text = "You must create a new socket connection"
		return false
