extends Node


var websocket_url = "ws://localhost:9089"
var socket := WebSocketPeer.new()

var signal_id:int = -1

var rtc = WebRTCMultiplayerPeer.new()

var ids:Dictionary = {}

func _ready():
	rtc.create_server()
	multiplayer.multiplayer_peer = rtc
	if socket.connect_to_url(websocket_url) != OK:
		log_message("Unable to connect.")
		return
	
	while socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		await get_tree().process_frame
	log_message("connected")
	socket.send_text(JSON.stringify({
		type=Multiplayer.SET_SERVER
	}))

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
				Multiplayer.START_RTC:
					var peer := WebRTCPeerConnection.new()
					ids[data.id] = peer
					peer.session_description_created.connect(peer.set_local_description)
					peer.session_description_created.connect(send_description.bind(data.id))
					
					peer.ice_candidate_created.connect(send_ice.bind(data.id))
					
					multiplayer.multiplayer_peer.add_peer(peer, data.id)
					
					peer.create_offer()
				Multiplayer.SET_DESCRIPTION:
					ids[data.id].set_remote_description(data.dtype,data.sdp)
				Multiplayer.SET_ICE:
					ids[data.id].add_ice_candidate(data.media,data.index,data.iname)

func send_description(type: String, sdp: String, id:int):
	socket.send_text(JSON.stringify({
		type=Multiplayer.SET_DESCRIPTION,
		id=id,
		dtype=type,
		sdp=sdp,
	}))

func send_ice(media: String, index: int, iname: String, id:int):
	socket.send_text(JSON.stringify({
		type=Multiplayer.SET_ICE,
		id=id,
		media=media,
		index=index,
		iname=iname
	}))

func _exit_tree():
	socket.close()

func log_message(_text):
	pass

func ping():
	socket.send_text("Ping")
