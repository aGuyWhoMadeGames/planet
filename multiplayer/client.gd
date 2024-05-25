extends Node


var websocket_url = "ws://localhost:9089"
var socket := WebSocketPeer.new()

var signal_id:int = -1
var server:int
var servers:Array

var rtc := WebRTCPeerConnection.new()
var network:WebRTCMultiplayerPeer

signal server_list

func _ready():
	network = WebRTCMultiplayerPeer.new()
	if socket.connect_to_url(websocket_url) != OK:
		log_message("Unable to connect.")
	else:
		log_message("connected")

func _process(_delta):
	socket.poll()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet().get_string_from_ascii()
			log_message(packet)
			var data = JSON.parse_string(packet)
			match int(data.type):
				Multiplayer.SET_ID:
					signal_id = data.id
					log_message("id: "+str(signal_id))
					socket.send_text(JSON.stringify({
						type=Multiplayer.GET_SERVERS
					}))
					network.create_client(signal_id)
					multiplayer.multiplayer_peer = network
					multiplayer.connected_to_server.connect(queue_free)
				Multiplayer.SERVER_LIST:
					servers = data.servers
					server_list.emit(servers)
				Multiplayer.SET_DESCRIPTION:
					rtc.set_remote_description(data.dtype,data.sdp)
				Multiplayer.SET_ICE:
					rtc.add_ice_candidate(data.media,data.index,data.iname)

func join(game):
	server = game
	socket.send_text(JSON.stringify({
		type=Multiplayer.START_RTC,
		id=server
	}))
	rtc.session_description_created.connect(rtc.set_local_description)
	rtc.session_description_created.connect(send_description)
	
	rtc.ice_candidate_created.connect(send_ice)
	
	network.add_peer(rtc, 1)

func send_description(type: String, sdp: String):
	socket.send_text(JSON.stringify({
		type=Multiplayer.SET_DESCRIPTION,
		id=server,
		dtype=type,
		sdp=sdp,
	}))

func send_ice(media: String, index: int, iname: String):
	socket.send_text(JSON.stringify({
		type=Multiplayer.SET_ICE,
		id=server,
		media=media,
		index=index,
		iname=iname
	}))

func _exit_tree():
	socket.close()

func log_message(_text):
	pass
	#$"../Label".text += text + "\n"

func ping():
	socket.send_text("Ping")
