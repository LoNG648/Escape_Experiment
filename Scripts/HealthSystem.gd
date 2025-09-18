class_name Health
extends Node

@export var maxHealth: float

var blockedDamage = false

@onready var currentHealth: float = maxHealth

func _ready() -> void:
	print(maxHealth)
	print(currentHealth)

func takeDamage(body: Node2D, damage: float) -> void:
	if body.blocking != true:
		currentHealth -= damage
		print("Ouch")
		print(body.name, " ", currentHealth)
		if currentHealth <= 0:
			body.death()
