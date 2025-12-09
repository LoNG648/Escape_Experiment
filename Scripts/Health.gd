# Generic Stuff 
class_name Health
extends Node

# Export Variables 
@export var maxHealth: float
@export var resistance: float

# On Ready Variables 
@onready var currentHealth: float = maxHealth

func _ready() -> void:
	#Prints all characters max health and current health at start if in DevMode
	if Globals.DeveloperMode == true:
		print(maxHealth)
		print(currentHealth)

func heal(healAmount: float) -> void:
	var parent = get_parent()
	currentHealth += healAmount
	currentHealth = clamp(currentHealth, 0, maxHealth)
	if Globals.DeveloperMode == true:
		print("Healed for ", healAmount, " amount")
		print(currentHealth)
	parent.label.visible = true
	parent.label.text = "+" + str(healAmount)
	parent.label.add_theme_color_override("font_color", Color.GREEN)
	await get_tree().create_timer(1.2).timeout
	parent.label.visible = false
	parent.label.remove_theme_color_override("font_color")

#Function to handle taking damage, which is only triggered when a character enters a hurtbox
func takeDamage(body: Node2D, damage: float, hurtbox, lifesteal: bool) -> void:
	#Damage is dealt normally if character is not blocking
	if body.blocking != true:
		currentHealth -= (damage*(clamp(100-resistance,10,100)/100))
		if lifesteal == true:
			hurtbox.get_parent().get_node("Health").heal((damage*(clamp(100-resistance,10,100)/100)))
	#Otherwise, character's damage is reduced by their set resistance amount
	elif body.blocking == true:
		body.blockedDamage()
	# Prints to make sure enemy is taking damage and how much damage is dealt. Only active in DevMode
	if Globals.DeveloperMode == true:
		print("Ouch")
		print(body.name, " ", currentHealth)
	#Causes body to die if the health is lowered to 0 or below
	if currentHealth <= 0:
		if body.get_script().get_global_name() == "Player" or hurtbox.get_parent().name == "Player" and body.get_script().get_global_name() in hurtbox.get_parent().absorbed:
			body.death()
		else:
			body.absorb()
	#Otherwise body just takes the respective damage amount
	else:
		body.got_hit(damage)
