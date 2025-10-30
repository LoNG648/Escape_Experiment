# Generic Stuff
class_name Hurtbox
extends Area2D

# Export Variables
@export var damage: float

# On Ready Variables
@onready var body: Node2D

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
		body.get_node("Health").takeDamage(body, damage)
