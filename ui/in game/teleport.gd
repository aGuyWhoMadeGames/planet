extends MenuButton


func _ready():
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	get_popup().id_pressed.connect(teleport)

func add_player(id:int):
	get_popup().add_item(str(id),id)

func remove_player(id:int):
	get_popup().remove_item(get_popup().get_item_index(id))

func teleport(id:int):
	var target:CharacterBody3D = $"../../../../players".get_node(str(id))
	GlobalData.player.transform = target.transform
	GlobalData.player.velocity = target.velocity
