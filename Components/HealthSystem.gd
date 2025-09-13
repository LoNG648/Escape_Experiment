class_name Health
extends Node

@export var maxHealth: float = 100.0
var currentHealth: float = maxHealth
@onready var sprite: AnimatedSprite2D = $"../Sprite"
@onready var hurtbox = get_node("/root/TestLevel/StaticBody2D/Hurtbox")

signal healthChanged(newHealth: float)

func _ready() -> void:
	print(maxHealth)
	print(currentHealth)
	hurtbox.connect("overlapOccurred",Callable(self,"_on_overlap_occurred"))
func _on_overlap_occurred(damage: float) -> void:
	currentHealth -= damage
	print("Ouch")
	print(currentHealth)
	if currentHealth <= 0:
		Dying()
	emit_signal("healthChanged", currentHealth)
func Dying() -> void:
	for i in range(4):
		sprite.rotation_degrees += 90
		await get_tree().create_timer(1).timeout
	print("Im Dying")
	Died()
func Died() -> void:
	sprite.scale.x = 5
	sprite.scale.y = 5
	print("I Died")
