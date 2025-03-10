extends Node

# Ask the server to create a match for the user
func create_match(logger : Control) -> bool:
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
