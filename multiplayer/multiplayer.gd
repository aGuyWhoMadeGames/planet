extends Node

enum {
	SET_ID,
	SET_SERVER,
	GET_SERVERS,
	SERVER_LIST,
	START_RTC,
	SET_DESCRIPTION,
	SET_ICE,
	SET_GAME
}

var server = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func host():
	server = true
	add_child(load("res://multiplayer/server.gd").new())

func join():
	add_child(load("res://multiplayer/client.gd").new())
