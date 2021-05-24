extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 4040
var token = null
var sceneChanged = false
var latency_array = []
var decimal_collector = 0.0
var latency = 0
var delta_latency = 0
var client_clock = 0

func _physics_process(delta):
	client_clock += int(delta * 1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00

func connect_to_server():
	network.create_client(ip,port)
	get_tree().set_network_peer(network)
	
	network.connect("connection_failed", self, "on_connection_failed")
	network.connect("connection_succeeded", self, "on_connection_succeeded")

func on_connection_failed():
	get_node("../Lobby/LoginScreen/").enable_confirm_popup("Failed to connect server, try again.", get_node("../Lobby/LoginScreen/"))

func on_connection_succeeded():
	get_node("../Lobby/LoginScreen/").set_label_popup("Successfully connect server.", get_node("../Lobby/LoginScreen/"))
	rpc_id(1, "fetch_server_time",OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", self, "determine_latency")
	self.add_child(timer)

remote func return_server_time(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency

func determine_latency():
	rpc_id(1, "determine_latency", OS.get_system_time_msecs())

remote func return_latency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size() -1, -1 , -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		latency_array.clear()

remote func fetch_token():
	rpc_id(1, "return_token", token)

remote func return_token_verification_results(result):
	if result:
		SceneManager.change_scene()
		get_node("../Lobby/LoginScreen/").set_label_popup("Successful connect", get_node("../Lobby/LoginScreen/"))
	else:
		get_node("../Lobby/LoginScreen/").enable_confirm_popup("Login failed, please try again.", get_node("../Lobby/LoginScreen/"))

func send_player_state(player_state):
	rpc_unreliable_id(1, "receive_player_state", player_state)

remote func receive_wolrd_state(world_state):
	if !sceneChanged:
		yield(SceneManager, "scene_started")
		sceneChanged = true
	get_node("../Main").update_world_state(world_state)

remote func spawn_new_player(player_id, spawn_position):
	if !sceneChanged:
		yield(SceneManager, "scene_started")
		sceneChanged = true
	get_node("../Main").spawn_new_player(player_id, spawn_position)

remote func despawn_player(player_id):
	get_node("../Main").despawn_player(player_id)

func fetch_skill_data(skill_name, requester):
	rpc_id(1,"fetch_skill_data", skill_name, requester)

remote func return_data_skill(s_skill_data, requester):
	instance_from_id(requester).set_data_skill(s_skill_data)

func fetch_player_stats():
	rpc_id(1, "fetch_player_stats")

remote func return_player_stats(stats):
	print(stats) #trocar pelo canvas
