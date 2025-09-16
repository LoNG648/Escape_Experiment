extends Area2D

@export var damage: float

func _on_body_entered(body: Node2D):
	if body.health:
		body.get_node("Health").takeDamage(body, damage)
