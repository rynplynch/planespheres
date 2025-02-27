extends Node

var _client : NakamaClient;
var _session : NakamaSession;
var _socket : NakamaSocket;

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

# Attempt account creation
func create_account(client : NakamaClient, email : String, password : String, logging : Control) -> void:
	logging.text = "Attempting account creation...\n"

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
	return
	
# Attempt session creation
func create_session(client : NakamaClient, email : String, password : String, logging : Control) -> NakamaSession:
	logging.text = "Attempting login...\n"

	# make sure the user has a working client
	if !await Networking.is_client_valid(client):
		logging.text = logging.text + "Your client is not valid.\n" + "Create a new client.\n"
		return null

	# ask nakama for a session token
	var session = await client.authenticate_email_async(email, password, null, false, null)

	# catch exception and inform the user
	if session.is_exception():
		logging.text = logging.text + "ERROR: " + str(session.get_exception().message)
		return null

	# make sure the session is valid
	if !is_session_valid(session):
		logging.text = logging.text + "Failed to create sesion.\n"
		return null
		
	return session

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
