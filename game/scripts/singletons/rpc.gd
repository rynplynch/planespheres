extends Node

# Ask the server to create a match for the user
func create_match(logger : Control) -> bool:
	# Everything we need to make the rpc call
	var client : NakamaClient = Networking._client
	var session : NakamaSession = Networking._session
	# The name the create_match function is registered with on the server
	var rpc_name : String = "create_match"
	
	# Check to make sure we can even make the call
	if await _is_ready(client, session, logger):
		# Let the user know we are performing work
		logger.text = "Attempting world creation...\n"
		
		# Attempt to call the rpc function
		var response : NakamaAPI.ApiRpc = await client.rpc_async(session, rpc_name)
		
		# Handle any errors
		if response.is_exception():
			# show the user the error
			logger.text = logger.text + response.exception.message + '\n'
			return false
		
		logger.text = logger.text + "World created!\n"
		return true
	
	# We can't make the call, Networking singleton will log info for user
	return false

# Ask the server to return a list of matches, based upon our request
func get_matches(logger : Control) -> bool:
	return false

# Helper functions
func _is_ready(client : NakamaClient, session : NakamaSession, logger : Control) -> bool:
	# Make sure the user has all the parts they need to make a call
	return await Networking.check_client_status(client, logger) \
	&& Networking.check_session_status(session, logger) \
	&& Networking.check_socket_status(logger)
