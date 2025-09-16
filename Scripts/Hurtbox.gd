extends Area2D

@export var damage: float

@onready var health_manager: Node = %HealthManager

func _on_body_entered(body: Node2D):
	if body.health:
		health_manager.takeDamage(body, damage)
