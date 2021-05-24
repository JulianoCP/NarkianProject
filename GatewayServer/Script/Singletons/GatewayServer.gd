extends Node2D

var cert = load("res://Certificate/X509_Certificate.crt")
var key = load("res://Certificate/X509_Key.key")

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 4140
var max_players = 100

func _ready():
	start_gateway_server()

func _process(_delta):
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func start_gateway_server():
	network.set_dtls_enabled(true)
	network.set_dtls_key(key)
	network.set_dtls_certificate(cert)
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("Gateway server started")
	
	network.connect("peer_connected", self, "on_peer_connected")
	network.connect("peer_disconnected", self, "on_peer_disconnected")

func on_peer_connected(player_id):
	print("User " + str(player_id) + " connected")

func on_peer_disconnected(player_id):
	print("User " + str(player_id) + " disconnected")

remote func login_request(username, password):
	var player_id = custom_multiplayer.get_rpc_sender_id()
	Authenticate.authentica_player(username, password, player_id)

func result_login_request(result, player_id, token):
	rpc_id(player_id, "result_login_request",result, token)
	network.disconnect_peer(player_id)

remote func create_account_request(username, password):
	var player_id = custom_multiplayer.get_rpc_sender_id()
	var valid_request = true
	if username == "": 
		valid_request = false
	if password == "":
		valid_request = false
	if password.length() <= 2:
		valid_request = false
	
	if valid_request == false:
		return_create_account_request(valid_request, player_id, 1)
	else:
		Authenticate.create_account(username.to_lower(), password, player_id)
		
func return_create_account_request(result, player_id, message):#message = 1 'failed' / = 2 'existing' / = 3 'welcome'
	rpc_id(player_id, "return_create_account_request", result, message)
	network.disconnect_peer(player_id)
