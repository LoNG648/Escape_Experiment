extends Area2D

@export var damage: float

@onready var health_manager: HealthManager = $HealthManager

func _on_body_entered(body: Node2D):
	print("Hi")
	if body.health:
		health_manager.takeDamage(body, damage)
