extends Node

@onready var MAX_CLIENTS = 10
@onready var PORT = 2000
# create new networking peer object
@onready var peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Create server
	peer.create_server(PORT, MAX_CLIENTS)
	# Inform godot networking api of current peer
	multiplayer.multiplayer_peer = peer
	print("server running on port " + str(PORT))
	
	peer.peer_connected.connect(
		func(new_peer_id):
			print("Peer with this id connected: " + str(new_peer_id))
			Rpc.print_once_per_client.rpc()
	)	
