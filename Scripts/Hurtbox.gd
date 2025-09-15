extends Area2D

@export var damage: float

signal takeDamage(body, damage)

func _on_body_entered(body: Node2D):
	emit_signal("takeDamage", body, damage)
