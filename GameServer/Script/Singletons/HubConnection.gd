extends Node

onready var gameserver = get_node("/root/GameServer")
var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 4041

func _ready():
	connect_to_server()

func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_server():
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "_connection_failed")
	network.connect("connection_succeeded", self, "_connection_succeeded")
	
func _connection_failed():
	print("Failed to connect to Game Server Hub")

func _connection_succeeded():
	print("Succefully connect Game Server Hub")

remote func receive_login_token(token):
	gameserver.expected_tokens.append(token)
