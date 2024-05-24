extends Node


@export var server = false
@export var ip = "localhost"
@export var port = 27016
@export var max_players = 50

var network_unique_id = 0

@onready var other_players_scene = preload("res://multiplayer/other players.tscn")
@onready var players = $"../players"
@onready var player = $"../player"

func _ready():
	$"../CanvasLayer/Control/pause_menu/MenuButton".get_popup().connect("id_pressed", Callable(self, "teleport"))
	if GlobalData.use_data:
		server = GlobalData.data["server"]
		if not server:
			ip = GlobalData.data["ip"]
	
	if server:
		create_server()
	else:
		create_client()


func create_server():
	network_unique_id = 1
	var network = ENetMultiplayerPeer.new()
	network.create_server(port, max_players)
	multiplayer.multiplayer_peer = network
	
	var _peer_connected = multiplayer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	var _peer_disconnected = multiplayer.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))

func create_client():
	# Set up an ENet instance
	var network = ENetMultiplayerPeer.new()
	network.create_client(ip, port)
	multiplayer.multiplayer_peer = network
	
	var _peer_connected = multiplayer.connect("peer_connected", Callable(self, "_on_peer_connected"))
	var _peer_disconnected = multiplayer.connect("peer_disconnected", Callable(self, "_on_peer_disconnected"))
	var _connected_to_server = multiplayer.connect("connected_to_server", Callable(self, "_on_connected_to_server"))
	var _connection_failed = multiplayer.connect("connection_failed", Callable(self, "_on_connection_failed"))
	var _server_disconnected = multiplayer.connect("server_disconnected", Callable(self, "_on_server_disconnected"))

func create_player(id):
	var new_player = other_players_scene.instantiate()
	new_player.name = str(id)
	new_player.set_multiplayer_authority(id)
	players.add_child(new_player)
	$"../CanvasLayer/Control/pause_menu/MenuButton".get_popup().add_item(str(id),id)

func remove_player(id):
	players.get_node(str(id)).free()
	$"../CanvasLayer/Control/pause_menu/MenuButton".get_popup().remove_item($"../CanvasLayer/Control/pause_menu/MenuButton".get_popup().get_item_index(id))

func _on_server_disconnected():
	#get_tree().quit()
	pass

func _on_peer_connected(id):
	# When other players connect a character and a child player controller are created
	create_player(id)

func _on_peer_disconnected(id):
	# Remove unused nodes when player disconnects
	remove_player(id)

func _on_connected_to_server():
	# Upon successful connection get the unique network ID
	# This ID is used to name the character node so the network can distinguish the characters
	network_unique_id = multiplayer.get_unique_id()
	#$chunks.ready = true


func _physics_process(_delta):
	rpc("update_position", player.transform)

@rpc("unreliable","any_peer") func update_position(position):
	players.get_node(str(multiplayer.get_remote_sender_id())).transform = position

@rpc("unreliable","any_peer") func update_view(rotation):
	var player = players.get_node(str(multiplayer.get_remote_sender_id()))
	player.get_node("Camera").rotation = rotation

func teleport(id):
	player.transform = players.get_node(str(id)).transform
