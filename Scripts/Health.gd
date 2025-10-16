class_name Health
extends Node

@export var maxHealth: float
@export var resistance: float = 50.0

@onready var currentHealth: float = maxHealth

func _ready() -> void:
	print(maxHealth)
	print(currentHealth)

func takeDamage(body: Node2D, damage: float) -> void:
	if body.blocking != true:
		currentHealth -= damage
	elif body.blocking == true:
		body.blockedDamage()
		currentHealth -= (damage*((100-resistance)/100))
	print("Ouch")
	print(body.name, " ", currentHealth)
	if currentHealth <= 0:
		body.death()
	else:
		body.got_hit(damage)
