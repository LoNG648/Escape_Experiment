class_name Hurtbox
extends Area2D

@export var damage: float

#@onready var body: Node2D

func _on_body_entered(body: Node2D):
	if body.health:
		body.get_node("Health").takeDamage(body, damage)

#func _on_area_entered(area: Area2D) -> void:
	#print("Area entered")
	#if area is Hitbox:
		#body = area.get_parent()
		#body.get_node("Health").takeDamage(body, damage)
