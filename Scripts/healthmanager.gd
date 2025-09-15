extends Node

@onready var hurtbox: Area2D = $Hurtbox

signal death()

func _ready() -> void:
	hurtbox.connect("takeDamage",Callable(self,"_on_take_damage"))
	
func _on_take_damage(body: Node2D, damage: float) -> void:
	if body.block != true:
		body.get_node("Health").currentHealth -= damage
		if body.name == "Player":
			print("Ouch")
			print(body.get_node("Health").currentHealth)
		if body.get_node("Health").currentHealth <= 0:
			emit_signal("death")
