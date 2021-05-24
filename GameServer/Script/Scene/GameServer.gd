extends Node

onready var player_verification = get_node("PlayerVerification")
onready var player_containers = get_node("PlayerStanceContainer")
onready var combat_node = get_node("Combat")

var network = NetworkedMultiplayerENet.new()
var port = 4040
var max_player = 100

var expected_tokens = []
var player_state_collection = {}

func _ready():
	start_server()

func start_server():
	network.create_server(port, max_player)
	get_tree().set_network_peer(network)
	print("Server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(player_id):
	print("User " + str(player_id) + " connected")
	player_verification.start(player_id)

func _peer_disconnected(player_id):
	print("User " + str(player_id) + " disconnected")
	if player_containers.has_node(str(player_id)):
		player_containers.get_node(str(player_id)).queue_free()
		player_state_collection.erase(player_id)
		rpc_id(0, "despawn_player", player_id)

func fetch_token(player_id):
	rpc_id(player_id, "fetch_token")

remote func return_token(token):
	var player_id = get_tree().get_rpc_sender_id()
	player_verification.verify(player_id, token)

func return_token_verification_results(player_id, result):
	rpc_id(player_id, "return_token_verification_results", result)
	if result == true:
		rpc_id(0, "spawn_new_player", player_id ,Vector2(0,0))

remote func receive_player_state(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state

func send_world_state(world_state):
	rpc_unreliable_id(0, "receive_wolrd_state", world_state)

remote func fetch_skill_data(skill_name, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var data = combat_node.fetch_skill_data(skill_name, player_id)
	rpc_id(player_id, "return_data_skill", data, requester)

remote func fetch_player_stats():
	var player_id = get_tree().get_rpc_sender_id()
	var player_stats = player_containers.get_node(str(player_id)).player_stats
	rpc_id(player_id, "return_player_stats", player_stats)
	
func _on_TokenExpiration_timeout():
	var current_time = OS.get_unix_time()
	var token_time
	if expected_tokens == []:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			token_time = int(expected_tokens[i].right(64))
			if current_time - token_time >= 30:
				expected_tokens.remove(i)

remote func fetch_server_time(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_server_time", OS.get_system_time_msecs(), client_time)

remote func determine_latency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "return_latency", client_time)
