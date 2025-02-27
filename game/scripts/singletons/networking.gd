extends Node

var _client : NakamaClient;
var _session : NakamaSession;
var _socket : NakamaSocket;

# Helper functions

# Returns true of the client can reach a Nakama server
func is_client_valid(_client : NakamaClient) -> bool:
	# check if client is null
	if !_client:
		return false
	
	# attempt to create a test sesion
	var _session = await _client.authenticate_custom_async("MyIdentifier")

	# only returns true of produced session is valid
	return is_session_valid(_session)
	
# Returns true if the session is valid 
func is_session_valid(_session : NakamaSession) -> bool:
	# return true if session is not null AND is valid AND is not expired
	return _session && _session.is_valid() && !_session.is_expired()
