extends StaticBody2D

@export var destructible := true

func _ready():
	pass

func on_hit(attack_type: String):
	if destructible and attack_type == "Special Attack":
		queue_free()  # removes the wall
