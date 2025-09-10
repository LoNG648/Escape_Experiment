class_name Health
extends Node

@export var maxHealth: float = 100.0
var currentHealth: float = maxHealth

signal healthChanged(newHealth)

func _ready() -> void:
	print(maxHealth)
	print(currentHealth)
func takedamage(damage: float) -> void:
	currentHealth -= damage
	if currentHealth <= 0:
		Dying()
	emit_signal("healthChanged", currentHealth)
func Dying():
	get_tree().create_timer(1)
	Died()
func Died() -> void:
	pass
