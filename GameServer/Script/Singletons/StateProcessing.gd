extends Node2D

var world_state

func _physics_process(_delta):
	if not get_parent().get_node(".").player_state_collection.empty():
		world_state = get_parent().player_state_collection.duplicate(true)
		for player in world_state.keys():
			world_state[player].erase("T")
		world_state["T"] = OS.get_system_time_msecs()
		#VERIFICATION
		#CHETS
		#CUTS
		#PHYSIC
		#ANOTHER
		get_parent().get_node(".").send_world_state(world_state)
