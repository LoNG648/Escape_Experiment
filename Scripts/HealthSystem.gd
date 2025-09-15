extends Node

@export var maxHealth: float = 100.0

var currentHealth: float = maxHealth

func _ready() -> void:
	print(maxHealth)
	print(currentHealth)
