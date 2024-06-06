extends Node

const PORT = 9089
var tcp_server := TCPServer.new()
var clients:Array[WebSocketPeer] = []
var ids:Dictionary = {}

var servers:Array[int] = []

func _ready():
	if tcp_server.listen(PORT) != OK:
		log_message("Unable to start server.")
	else:
		log_message("Server Started")

func _process(_delta):
	while tcp_server.is_connection_available():
		var conn: StreamPeerTCP = tcp_server.take_connection()
		create_client(conn)

	for id in ids:
		var socket:WebSocketPeer = ids[id]
		socket.poll()
		#print("signal poll")
		
		if socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
			remove_client.bind(id).call_deferred()
		
		if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			while socket.get_available_packet_count():
				var packet = socket.get_packet().get_string_from_ascii()
				log_message(packet)
				var data = JSON.parse_string(packet)
				match int(data.type):
					Multiplayer.SET_SERVER:
						servers.append(id)
					Multiplayer.GET_SERVERS:
						socket.send_text(JSON.stringify({
							type=Multiplayer.SERVER_LIST,
							servers=servers
						}))
					Multiplayer.START_RTC:
						if int(data.id) in servers:
							ids[int(data.id)].send_text(JSON.stringify({
								type=Multiplayer.START_RTC,
								id=id
							}))
					Multiplayer.SET_DESCRIPTION:
						var to_id = int(data.id)
						data.id = id
						ids[to_id].send_text(JSON.stringify(data))
					Multiplayer.SET_ICE:
						var to_id = int(data.id)
						data.id = id
						ids[to_id].send_text(JSON.stringify(data))

func remove_client(id):
	clients.erase(ids[id])
	ids.erase(id)
	if id in servers:
		servers.erase(id)

func create_client(conn:StreamPeerTCP):
	assert(conn != null)
	var socket := WebSocketPeer.new() 
	socket.accept_stream(conn)
	var id:int = randi()%(1<<31)
	ids[id] = socket
	clients.append(socket)
	log_message("client connecting...")
	while socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		await get_tree().process_frame
	socket.send_text(JSON.stringify({
		type=Multiplayer.SET_ID,
		id=id
	}))
	log_message("client connected; id: "+str(id))

func _exit_tree():
	for client in clients: client.close()
	tcp_server.stop()

func log_message(text):
	$"../Label".text += text + "\n"

func ping():
	for socket in clients: socket.send_text("Ping")
