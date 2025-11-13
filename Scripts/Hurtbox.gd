# Generic Stuff
class_name Hurtbox
extends Area2D

# Export Variables
@export var damage: float

# On Ready Variables
@onready var body: Node2D
@onready var hurtbox: Hurtbox = $"."

#func _on_body_entered(body: Node2D):
	#if body.health:
		#body.get_node("Health").takeDamage(body, damage)

#Activates when the hurtbox is entered and only deals damage if respective thing that entered had a hitbox
func _on_area_entered(area: Area2D) -> void:
	#Generic developer print to understand this function got triggered and only active in DevMode
	if Globals.DeveloperMode == true:
		print("Area entered")
	if area is Hitbox:
		#Print to understand that a hitbox was found and this is only shown while in DevMode
		if Globals.DeveloperMode == true:
			print("Hitbox found")
		#Code to grab the parent of the hitbox area which is the respective player/enemy and then call the takeDamage function for the said player/enemy
		body = area.get_parent()
		if hurtbox.name == "Collector Special Attack Hurtbox":
			body.get_node("Health").takeDamage(body, damage, hurtbox, true)
		else:
			body.get_node("Health").takeDamage(body, damage, hurtbox, false)
		
		if hurtbox.get_parent().name == "Player":
			if body not in hurtbox.get_parent().absorbed:
				if body is Tank_Boss and body.get_node("Health").currentHealth <= 0:
					hurtbox.get_parent()._on_tank_boss_defeated()
				elif body is Basic_Enemy and body.get_node("Health").currentHealth <= 0:
					hurtbox.get_parent()._on_basic_enemy_defeated()
				elif body is Complex_Enemy and body.get_node("Health").currentHealth <= 0:
					hurtbox.get_parent()._on_complex_enemy_defeated()
