extends Node2D

var state = "Idle"

onready var animation_player = get_node("AnimationPlayer")
onready var animation_tree = get_node("AnimationTree")
onready var animation_state = animation_tree.get("parameters/playback")

func move_player(new_position, direction_parameters):
	animation_tree.set("parameters/Player_walking/blend_position",direction_parameters)
	animation_tree.set("parameters/Player_idle/blend_position",direction_parameters)
	if new_position == position:
		animation_state.travel("Player_idle")
	else:
		animation_state.travel("Player_walking")
		set_position(new_position)
