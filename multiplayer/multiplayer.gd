extends Node

enum {
	SET_ID,
	SET_SERVER,
	GET_SERVERS,
	SERVER_LIST,
	START_RTC,
	SET_DESCRIPTION,
	SET_ICE,
}

var server = false

var time = 0.0
var last_sync = 0.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func host():
	server = true
	add_child(load("res://multiplayer/server.gd").new())

func join():
	add_child(load("res://multiplayer/client.gd").new())

func _process(delta: float) -> void:
	time += delta
	
	if server and time - last_sync > 0.5:
		last_sync = time
		set_time.rpc(time)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func set_time(t):
	time = t
