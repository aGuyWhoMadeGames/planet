extends MultiplayerSpawner

@export var player:PackedScene
@export var other:PackedScene

func _ready():
	spawn_function = func(id):
		var node:Node3D
		node = player.instantiate()
		#if id == multiplayer.get_unique_id():
			#node = player.instantiate()
		#else:
			#node = other.instantiate()
		node.position = Vector3(0,10,0)
		node.name = str(id)
		node.set_multiplayer_authority(id)
		return node
	
	
	if Multiplayer.server:
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(peer_disconnected)
		spawn(1)

func peer_disconnected(id):
	get_node(str(id)).queue_free()
