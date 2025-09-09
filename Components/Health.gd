class_name Health
extends Node

@export var maxHealth: float
var currentHealth: float = maxHealth
@onready var damage: float

func _init(maxHealth: float):
	self.maxHealth = maxHealth
	self.currentHealth = maxHealth

func takedamage(damage: float):
	currentHealth -= damage
	if currentHealth <= 0:
		Dying()
func Dying():
	get_tree().create_timer(1)
	Died()
func Died():
	pass
