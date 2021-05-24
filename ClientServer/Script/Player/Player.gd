extends KinematicBody2D

var velocity = Vector2.ZERO
var animation_vector = Vector2.ZERO
var direction_parameters = Vector2.ZERO
var speed_player = 140
var player_state
var moving = false
var attacking = false
enum {SLASH, TYPHOON}
var curret_skill = SLASH

onready var animation_player = get_node("AnimationPlayer")
onready var animation_tree = get_node("AnimationTree")
onready var animation_state = animation_tree.get("parameters/playback")

var slash_attack = preload("res://Prefab/Instance/SlashWar.tscn")

func _physics_process(_delta):
	movimentLoop()
	define_player_state()

func movimentLoop():
	if (Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")) and !attacking:
		animation_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		animation_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if Input.is_action_pressed("ui_right_mouse"):
		attacking = true
	else:
		attacking = false

	animation_vector = animation_vector.normalized()
	if animation_vector != Vector2.ZERO:
		direction_parameters = animation_vector
	else:
		velocity = Vector2.ZERO

	if attacking:
		match curret_skill:
			SLASH:
				animation_tree.set("parameters/Special_attack_one/blend_position",direction_parameters)
				animation_state.travel("Special_attack_one")
				Special_attack_one()
			TYPHOON:
				print("Ola")
	else:
		if animation_vector != Vector2.ZERO:
			animation_tree.set("parameters/Player_walking/blend_position",direction_parameters)
			animation_state.travel("Player_walking")
			velocity = animation_vector * speed_player
		elif animation_vector == Vector2.ZERO:
			animation_tree.set("parameters/Player_idle/blend_position",direction_parameters)
			animation_state.travel("Player_idle")
			velocity = Vector2.ZERO
	
	animation_vector = Vector2.ZERO
	velocity = move_and_slide(velocity.round())

func define_player_state():
	player_state = {"T": GameServer.client_clock, "P": get_global_position(), "A": direction_parameters}
	GameServer.send_player_state(player_state)

func Special_attack_one():
	print("Ue")
