extends Node2D

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 4141

func _ready():
	connect_to_server_authenticate()

func connect_to_server_authenticate():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "on_connection_failed")
	network.connect("connection_succeeded", self, "on_connection_succeeded")

func on_connection_failed():
	print("Failed to connect to authentication server")

func on_connection_succeeded():
	print("Succesfully to connect to authentication server")

func create_account(username, password, player_id):
	rpc_id(1, "create_account", username,password, player_id)

remote func result_create_account(result, player_id, message):
	GatewayServer.return_create_account_request(result, player_id, message)

func authentica_player(username, password, player_id):
	rpc_id(1, "authentica_player", username, password, player_id)

remote func authentication_results(result, player_id, token):
	GatewayServer.result_login_request(result, player_id, token)
