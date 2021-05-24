extends StaticBody2D

var damage

func set_damage(value):
	damage = value

func get_damage():
	return damage

func _on_Timer_timeout():
	queue_free()
