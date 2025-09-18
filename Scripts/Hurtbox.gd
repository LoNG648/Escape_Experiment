class_name Hurtbox
extends Area2D

@export var damage: float

func _on_body_entered(body: Node2D):
	print(body.get_node("Something").get_overlapping_areas())
	if body is not player:
		print("Enemy spotted")
	if body.health:
		body.get_node("Health").takeDamage(body, damage)
