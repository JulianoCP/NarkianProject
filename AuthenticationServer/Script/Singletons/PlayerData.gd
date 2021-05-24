extends Node

var PlayerIDs = null

func _ready():
	get_data_playerIDs()

func save_playerIDs():
	var save_file = File.new()
	save_file.open("res://Data/Accounts/AccountsData.json",File.WRITE)
	save_file.store_line(to_json(PlayerIDs))
	save_file.close()

func return_data_player(username):
	if PlayerIDs.has(str(username)):
		return PlayerIDs[str(username)]
	else:
		return false

func get_data_playerIDs():
	var file = File.new()
	file.open("res://Data/Accounts/AccountsData.json",File.READ)
	var json_file = JSON.parse(file.get_as_text())
	file.close()
	PlayerIDs = json_file.result
