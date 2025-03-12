extends Control

# select appropriate node via the editor
@export_node_path("Label") var logger_path : NodePath
@export_node_path("Tree") var match_list_tree_path : NodePath
@export_file("*.tscn") var networking_menu_path : String

# networking menu to swap out our match menu UI module
@onready var networking_menu : PackedScene = load(networking_menu_path)

# used to provide feedback to the user
@onready var logger : Label = get_node(logger_path)

# used to hold matches data
@onready var match_list : Array = []
# used to display certain data from match list
@onready var match_list_tree : Tree = get_node(match_list_tree_path)

func _ready() -> void:
	match_list_tree.columns = 2
	match_list_tree.set_column_title(0, "Match ID")
	match_list_tree.set_column_title(1, "Players")
	match_list_tree.set_column_expand(0, true)
	match_list_tree.set_column_expand(1, true)
	match_list_tree.set_column_expand_ratio(0,5)
	match_list_tree.set_column_expand_ratio(1,1)


func _on_create_match_pressed() -> void:
	Rpc.create_match(logger)

func _on_refresh_matches_pressed() -> void:
	# remove any exisitng matches from the tree and list
	match_list.clear()
	match_list_tree.clear()
	var root = match_list_tree.create_item()
	
	# properties used to query the nakama server
	var payload = {
	"limit" : 10,
	"isAuthoritative" : true,
	"label" : "",
	"min_size" : 0,
	"max_size" : 4,
	"query" : "" 
	}
	
	# get the list of matches from nakama
	match_list = await Rpc.get_matches(payload, logger)

	# loop through the list of matches
	for m in match_list:
		# create a new node in the tree of matches
		var world : TreeItem = match_list_tree.create_item(root)
		world.set_text(0, m["match_id"])
		world.set_text(1, str(m["size"]))
		world.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)

func _on_return_to_networking_pressed() -> void:
	# load the networking menu UI model into the scene tree
	get_parent().add_child(networking_menu.instantiate())

	# remove the match menu UI from the scene tree
	self.queue_free()

func _on_join_world_pressed() -> void:
	# make sure there is an available socket
	if Networking.check_socket_status(logger):
		
		# get the selected world from the tree
		var selected : TreeItem = match_list_tree.get_selected()
		
		# if the user did not select a TreeItem
		if selected == null:
			return
