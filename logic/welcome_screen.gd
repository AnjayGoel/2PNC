extends Control

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 8910

onready var address = $address
onready var host_button = $host
onready var join_button = $join
onready var cancel_button = $cancel
onready var status = $status



var peer = null

func _ready():
	# Connect all the callbacks related to networking.
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	#get_tree().connect("end_game", self, "_end_game")
	var root = get_tree().get_root()
	Utils.welcome_scene = root.get_child(root.get_child_count() - 1)




# Callback from SceneTree.
func _player_connected(_id):
	print("Player Con")
	cancel_button.hide()
	hide()
	Transit.fade_scene("game_list",true)


func _player_disconnected(_id):
	print("Player Dis")
	if get_tree().is_network_server():
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	pass # This function is not needed for this project.


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	_set_status("Couldn't connect", false)

	get_tree().set_network_peer(null) # Remove peer.
	host_button.set_disabled(false)
	join_button.set_disabled(false)


func _server_disconnected():
	print("Server Dis")
	_end_game("Server disconnected")


func _end_game(with_error = ""):
	var cnt = 0
	for node in get_tree().get_root().get_children():
		node.hide()
		cnt = cnt+1
	print("Count: %d"%cnt)
	show()
	get_tree().set_network_peer(null) # Remove peer.
	host_button.set_disabled(false)
	join_button.set_disabled(false)
	
	if (with_error!=""):
		_set_status(with_error, false)
	else:
		_set_status("Host or join a game!",false)



func _on_cancel_pressed ():
	get_tree().set_network_peer(null)
	host_button.set_disabled(false)
	join_button.set_disabled(false)
	cancel_button.hide()
	_set_status("Host or join a game!",true)

func _set_status(text, isok):
	print(isok)
	status.set_text(text)

func _on_host_pressed():
	print("Host Start")
	cancel_button.show()
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = peer.create_server(DEFAULT_PORT, 1) # Maximum of 1 peer, since it's a 2-player game.
	if err != OK:
		# Is another server running?
		_set_status("Can't host, address in use.",false)
		return
	get_tree().set_network_peer(peer)
	print("Waiting")
	_set_status("Connect to %s, Waiting for player..."%Utils.get_ip(), true)




func _on_join_pressed():
	print("Join Pressed")
	cancel_button.show()
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	var ip = address.get_text()
	print("Join --%s--"%ip)
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid", false)
		return

	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)

	_set_status("Connecting...", true)
