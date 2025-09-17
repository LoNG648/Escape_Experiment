extends Node

@export var maxHealth: float = 100.0

var currentHealth: float = maxHealth

func _ready() -> void:
	print(maxHealth)
	print(currentHealth)

func takeDamage(body: Node2D, damage: float) -> void:
	if body.blocking != true:
		currentHealth -= damage
		if body is player:
			print("Ouch")
			print(currentHealth)
		if currentHealth <= 0:
			body.death()
