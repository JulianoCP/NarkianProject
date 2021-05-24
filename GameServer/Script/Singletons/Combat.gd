extends Node

func fetch_skill_data(skill_name, _player_id):
	#Para depois eu manipular o dano das habilidades posso usar isso:
	#(0.1 playerStanceContainer.get_node(str(player_id)).player_stats.Intelligence)
	var data = ServerData.return_data_skill(skill_name)
	if data == null:
		return null
	return data
