class_name HealthManager
extends Node

signal death()
	
func takeDamage(body: Node2D, damage: float) -> void:
	if body.block != true:
		body.get_node("Health").currentHealth -= damage
		if body is player:
			print("Ouch")
			print(body.get_node("Health").currentHealth)
		if body.get_node("Health").currentHealth <= 0:
			emit_signal("death")
