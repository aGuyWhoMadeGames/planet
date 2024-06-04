extends MultiplayerSpawner

@export var player:PackedScene


func _ready():
	spawn_function = func(id):
		var node:Node3D
		node = player.instantiate()
		node.position = Vector3(0,10,0)
		node.name = str(id)
		node.set_multiplayer_authority(id)
		if id == multiplayer.get_unique_id():
			var map = \
			$"../CanvasLayer/Control/map/AspectRatioContainer/Control/ColorRect"
			map.player = node
		return node
	
	if Multiplayer.server:
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(peer_disconnected)
		spawn(1)

func peer_disconnected(id):
	get_node(spawn_path).get_node(str(id)).queue_free()

func peer_connected(id):
	var node = player.instantiate()
	node.name = str(id)
	get_node(spawn_path).add_child(node)
