extends Node

var cert = load("res://Resource/Certificate/X509_Certificate.crt")
var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var ip = "127.0.0.1"
var port = 4140

var username
var password
var new_account = false

func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_server(_username,_password, _new_account):
	network = NetworkedMultiplayerENet.new()
	gateway_api = MultiplayerAPI.new()
	network.set_dtls_enabled(true)
	network.set_dtls_verify_enabled(false)
	network.set_dtls_certificate(cert)
	username = _username
	password = _password
	new_account = _new_account
	network.create_client(ip, port)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_failed", self, "on_connection_failed")
	network.connect("connection_succeeded", self , "on_connection_succeeded")
	
func on_connection_failed():
	get_node("../Lobby/LoginScreen/").enable_confirm_popup("Failed to connect gateway, try again.", get_node("../Lobby/LoginScreen/"))

func on_connection_succeeded():
	get_node("../Lobby/LoginScreen/").set_label_popup("Successfully connect login server.", get_node("../Lobby/LoginScreen/"))
	if new_account:
		request_create_account()
	else:
		request_login()

func request_create_account():
	rpc_id(1, "create_account_request", username, password.sha256_text())
	username = ""
	password = ""

remote func return_create_account_request(result, message):
	if result:
		get_node("../Lobby/LoginScreen/").return_to_login_screen()
		get_node("../Lobby/LoginScreen/").enable_confirm_popup("Successfully created account.", get_node("../Lobby/LoginScreen/"))
		get_node("../Lobby/LoginScreen/CreateAccountContainer").enable_button_login()
	else:
		if message == 1:
			get_node("../Lobby/LoginScreen/").enable_confirm_popup("Couldn't create account, try again.", get_node("../Lobby/LoginScreen/CreateAccountContainer"))
		if message == 2:
			get_node("../Lobby/LoginScreen/").enable_confirm_popup("Username already existe, try again.", get_node("../Lobby/LoginScreen/CreateAccountContainer"))
		network.disconnect("connection_failed", self, "on_connection_failed")
		network.disconnect("connection_succeeded", self, "on_connection_succeeded")

func request_login():
	get_node("../Lobby/LoginScreen/").set_label_popup("Trying connection...", get_node("../Lobby/LoginScreen/"))
	rpc_id(1,"login_request", username, password.sha256_text())
	username = ""
	password = ""

remote func result_login_request(result, token):
	if result:
		GameServer.token = token
		GameServer.connect_to_server()
		get_node("../Lobby/LoginScreen/").set_label_popup("Trying connection...", get_node("../Lobby/LoginScreen/"))
	else:
		get_node("../Lobby/LoginScreen/").enable_confirm_popup("Please provide correct username and password.", get_node("../Lobby/LoginScreen/"))
	network.disconnect("connection_failed", self, "on_connection_failed")
	network.disconnect("connection_succeeded", self, "on_connection_succeeded")
