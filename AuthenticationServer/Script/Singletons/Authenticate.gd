extends Node

var network = NetworkedMultiplayerENet.new()
var port = 4141
var max_servers = 5

func _ready():
	start_authenticate_server()

func start_authenticate_server():
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Authentication server started")
	
	network.connect("peer_connected", self, "peer_connected")
	network.connect("peer_disconnected", self, "peer_disconnected")

func peer_connected(gateway_id):
	print("Gateway " + str(gateway_id) + " connected")

func peer_disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " disconnected")

remote func create_account(username, password, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var message
	
	if PlayerData.PlayerIDs.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt = generate_salt()
		var hashed_password = generate_hashed_password(password, salt)
		PlayerData.PlayerIDs[username] = {"password": hashed_password, "salt": salt}
		PlayerData.save_playerIDs()
	rpc_id(gateway_id, "result_create_account", result, player_id, message)

func generate_salt():
	randomize()
	var salt = str(randi()).sha256_text()
	return salt

func generate_hashed_password(password, salt):
	var hashed_password = password
	var rounds = pow(2, 8)
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	return hashed_password

remote func authentica_player(username, password, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var hashed_password
	var result = true
	var token = null
	var player_data = PlayerData.return_data_player(username)
	if not player_data:
		result = false
	else:
		var retrived_salt = player_data.salt
		hashed_password = generate_hashed_password(password, retrived_salt)
		if not player_data.password == hashed_password:
			result = false
		else:
			result = true
			randomize()
			token = str(randi()).sha256_text() + str(OS.get_unix_time())
			var gameserver = "GameServer1"
			GameServers.distribute_login_token(token, gameserver)
		
	rpc_id(gateway_id,"authentication_results", result, player_id, token)
