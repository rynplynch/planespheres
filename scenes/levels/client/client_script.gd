extends Node2D

@onready var screen_name : Label = $"ScreenName"
@onready var session_token : Label = $"SessionToken"

#var token_request = JavaScriptBridge.create_callback(_on_token_request)
#
#var console
#func _init() -> void:
#	# send javascript to be evaluated by the users browser
#	JavaScriptBridge.eval("""
#// this objects reference is shared between Godot and the browsers Javascript
#var godotBridge = {
#	// a refernce to a Godot function
#	callback: null,
#	// sets the refernce to the Godot function
#	setCallback: (cb) => this.callback = cb,
#	// javascript function that calls Godot function
#	sendCookie: (data) => this.callback(JSON.stringify(data)),
#};
#	""", true)
#	# grab the reference to the Javascript object we just created
#	var godot_bridge = JavaScriptBridge.get_interface("godotBridge")
#
#	# set the reference to the Godot function so the browser can call it later
#	godot_bridge.setCallback(token_request)
#
#	# ask the clients broswer to send us the logged in users data
#
#
## function that gets called by Javascript on users browser
#func _on_token_request(args) -> void:
#	# there is only ever 1 argument passed by Javascript
#	# for this reason multiple arguments are passed in JSON format
#	var json = JSON.parse_string(args[0])
#
#	# read in sensitive data from the web client
#	# the web client will call this function, passing in the data
#	if "session_token" in json:
#		# store the session_token for later use
#		AuthenticationCredentials.session_token = json["session_token"]
#
#	if "screen_name" in json:
#		# store screen_name for later use
#		AuthenticationCredentials.screen_name = json["screen_name"]
#
