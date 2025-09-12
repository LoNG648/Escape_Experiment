class_name Health
extends Node

@export var maxHealth: float = 100.0
var currentHealth: float = maxHealth

signal healthChanged(newHealth: float)

func _ready() -> void:
	print(maxHealth)
	print(currentHealth)
	var hurtbox = get_node("/root/TestLevel/StaticBody2D/Hurtbox")
	hurtbox.connect("overlapOccured",Callable(self,"on_overlap_occurred"))
func _on_overlap_occurred(damage: float) -> void:
	currentHealth -= damage
	print("Ouch")
	print(currentHealth)
	if currentHealth <= 0:
		Dying()
	emit_signal("healthChanged", currentHealth)
func Dying() -> void:
	print("Im Dying")
	get_tree().create_timer(1)
	Died()
func Died() -> void:
	print("I Died")
