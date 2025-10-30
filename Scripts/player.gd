# Generic Stuff
class_name Player
extends CharacterBody2D

#Constants
const SPEED = 250.0 #Horizontal Speed
const JUMP_VELOCITY = -450.0 #Jump Height and Speed

#Regular Variables
var dead: bool = false #Is character dead?
var blocking: bool = false #Is character blocking?
var attacking: bool = false #Is character attacking?
var specialAttacking: bool = false #Is character Special Attacking?
var counterAttackStored: bool = false #Does character have a counter attack?
var facing: bool = true #Which direction is the character facing (left is false, right is true)
var hearts_list : Array[TextureRect]
var moveset: Array = ["baseAttack","baseSpecial","baseCounter","baseBlock"]
var basicAttack: String = moveset[0]
var specialAttack: String = moveset[1]
var counterAttack: String = moveset[2]
var block: String = moveset[3]

#On Ready Variables
@onready var collector_sprite: AnimatedSprite2D = $CollectorSprite
@onready var tank_sprite: AnimatedSprite2D = $TankSprite
@onready var health: Node = $Health #Health Variable
@onready var collector_special_attack: Node2D = $"Collector Special Attack"
@onready var collector_basic_attack_hurtbox_collision: CollisionShape2D = $"Collector Basic Attack Hurtbox/Collector Basic Attack Hurtbox Collision"
@onready var tank_basic_attack_hurtbox_collision: CollisionShape2D = $"Tank Basic Attack Hurtbox/Tank Basic Attack Hurtbox Collision"
@onready var collector_counter_attack_hurtbox_collision: CollisionShape2D = $"Collector Counter Attack Hurtbox/Collector Counter Attack Hurtbox Collision"
@onready var tank_counter_attack_hurtbox_collision: CollisionShape2D = $"Tank Counter Attack Hurtbox/Tank Counter Attack Hurtbox Collision"
@onready var shockwave_sprite: AnimatedSprite2D = $"Shockwave Sprite"
@onready var tank_special_attack_hurtbox_collision: CollisionShape2D = $"Tank Special Attack Hurtbox/Tank Special Attack Hurtbox Collision"
@onready var crouch_timer: Timer = $"Timers/Crouch Timer"
@onready var counter_attack_timer: Timer = $"Timers/Counter Attack Timer"
@onready var block_timer: Timer = $"Timers/Block Timer"
@onready var animation_timer: Timer = $"Timers/Animation Timer"
@onready var health_ui: CanvasLayer = $HealthUI

func _ready() -> void:
	#Sets up Healthbar UI
	var hearts_parents = health_ui.get_node("HBoxContainer")
	for child in hearts_parents.get_children():
		hearts_list.append(child)

#Function that sets counter attack to true if character has blocked damage so they can retaliate back!
func blockedDamage():
	#Developer print to understand this function was called; only active in Devmode
	if Globals.DeveloperMode == true:
		print("Nope!")
	#Resets counter attack timer if there was already an opportunity to counter attack
	if counterAttackStored == true:
		counter_attack_timer.start()
		return
	#Sets counter attack to true and starts the counter attack timer if there was not already an opportunity to counter attack
	elif counterAttackStored == false:
		counterAttackStored = true
		counter_attack_timer.start()
	await counter_attack_timer.timeout
	#Developer print to know that the counter attack is lost
	if Globals.DeveloperMode == true:
		print("Counter Attack Lost")
	#Counter attack proceeds to get lost after not using it in the window of opportunity after a successful block
	counterAttackStored = false

func _physics_process(delta: float) -> void:
	#Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("Move Left","Move Right")
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Disables code hereafter if dead to not allow player movement and attacks
	if dead:
		return
	
	#Handles updates to player Health in real time for the UI
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < (health.currentHealth/10)
	
	#Animation code which only runs if no existing animation is running
	if animation_timer.get_time_left() == 0:
		#Resets sprite to its normal position (since other animations have a weird offset)
		collector_sprite.position = Vector2(0, -42)
		if is_on_floor():
			if direction == 0:
				#Plays idle animation if not moving
				collector_sprite.play("Idle")
			else:
				#Plays run animation if actively moving
				collector_sprite.play("Run")
		else:
			#Plays jump animation if not on the ground
			collector_sprite.play("Jump")
		
		#Handles jump by making character jump their respective jump height if on the ground and inputs jump
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		#Applies Horizontal Movement
		if direction:
			#Sets horizontal movement speed based on direction and player speed stat
			velocity.x = direction * SPEED
			#Flips character if moving in opposite direction from previous facing direction
			if velocity.x < 0 and facing == true:
				scale.x = abs(scale.x) * -1
				#Facing is set to false, meaning character is facing left
				facing = false
			if velocity.x > 0 and facing == false:
				scale.x = abs(scale.x) * -1
				#Facing is set to true, meaning character is facing right
				facing = true
		else:
			#Deaccelerates character down to a stop if not actively pressing a movement input
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		#Handles crouch and reduces Hitbox
		if Input.is_action_just_pressed("Crouch"):
			#Only reduces overall player size if character wasn't already crouching
			if crouch_timer.get_time_left() == 0:
				scale.y /= 2
			#Pauses the crouch timer which allows for crouch to be held by player not releasing the crouch button
			crouch_timer.paused = true
		
		#Sets a delay before crouching can be done again and resets hitbox
		if Input.is_action_just_released("Crouch"):
			#Unpauses and resets timer if timer was already begun. Additionally removes multiple instances of code waiting on crouch timer's timeout by the return line
			if crouch_timer.get_time_left() != 0:
				crouch_timer.paused = false
				crouch_timer.start()
				return
			#Unpauses and starts the crouch timer if it was not already started
			elif crouch_timer.get_time_left() == 0:
				crouch_timer.paused = false
				crouch_timer.start()
			await crouch_timer.timeout
			#Player's scale is reset to normal once the crouch delay is completed
			scale.y *= 2
		
		#Attack and Counterattack Mechanic
		if Input.is_action_just_pressed("Basic Attack"):
			if Globals.DeveloperMode == true:
				print(counterAttackStored)
			#Promotes the attack to a counter attack if possible
			if counterAttackStored == true:
				#Determines counter attack type based off selected moveset and plays respective counter
				if counterAttack == "baseCounter":
					collector_sprite.position = Vector2(2, -42)
					collector_sprite.play("Counter Attack")
					attacking = true
					animation_timer.start(2)
					collector_counter_attack_hurtbox_collision.disabled = false
					await get_tree().create_timer(0.5).timeout
					collector_counter_attack_hurtbox_collision.disabled = true
					await animation_timer.timeout
					attacking = false
					counterAttackStored = false
				elif counterAttack == "tankCounter":
					collector_sprite.visible = false
					tank_sprite.visible = true
					tank_sprite.play("Counter Attack")
					attacking = true
					animation_timer.start(4)
					tank_counter_attack_hurtbox_collision.disabled = false
					await get_tree().create_timer(0.25).timeout
					tank_counter_attack_hurtbox_collision.disabled = true
					await animation_timer.timeout
					attacking = false
					counterAttackStored = false
					collector_sprite.visible = true
					tank_sprite.visible = false
			else:
				#Determines basic attack off of moveset selected and plays respective basic attack
				if basicAttack == "baseAttack":
					#Does a basic attack if can't do a counter attack
					collector_sprite.position = Vector2(14, -33)
					collector_sprite.play("Attack")
					animation_timer.start(1)
					attacking = true
					collector_basic_attack_hurtbox_collision.disabled = false
					await get_tree().create_timer(0.2).timeout
					collector_basic_attack_hurtbox_collision.disabled = true
					await animation_timer.timeout #Basic Attack Delay
					attacking = false
				elif basicAttack == "tankAttack":
					collector_sprite.visible = false
					tank_sprite.visible = true
					tank_sprite.play("Attack")
					animation_timer.start(2)
					attacking = true
					tank_basic_attack_hurtbox_collision.disabled = false
					await get_tree().create_timer(0.4).timeout
					tank_basic_attack_hurtbox_collision.disabled = true
					await animation_timer.timeout
					attacking = false
					collector_sprite.visible = true
					tank_sprite.visible = false
		
		#Apply Blocking Mechanic
		if Input.is_action_just_pressed("Block"):
			#Determines block type from moveset and conducts proper selected block
			if block == "baseBlock":
				collector_sprite.position = Vector2(2, -42)
				animation_timer.start(1)
				collector_sprite.play("Block")
				blocking = true
				block_timer.start(0.5)
				await block_timer.timeout
				collector_sprite.set_frame_and_progress(5,0)
				collector_sprite.pause()
				animation_timer.paused = true
				print(collector_sprite.frame)
			elif block == "tankBlock":
				collector_sprite.visible = false
				tank_sprite.visible = true
				animation_timer.start(1)
				print(animation_timer.get_time_left())
				tank_sprite.play("Block")
				blocking = true
				block_timer.start(0.5)
				await block_timer.timeout
				tank_sprite.pause()
				animation_timer.paused = true
		
		#Special Attack Mechanic which causes damage to enemy while bypassing the Hurtbox code
		if Input.is_action_just_pressed("Special Attack"):
			if Globals.DeveloperMode == true:
				print("SPECIAL!")
			#Determines which special is active and plays the proper special
			if specialAttack == "baseSpecial":
				collector_sprite.position = Vector2(14, -33)
				collector_sprite.play("Special Attack")
				collector_special_attack.get_node("Dev Line").visible = true
				animation_timer.start(0.25)
				collector_special_attack.get_node("Special Attack Raycast").enabled = true
				if collector_special_attack.get_node("Special Attack Raycast").is_colliding():
					if collector_special_attack.get_node("Special Attack Raycast").get_collider() is Hitbox:
						collector_special_attack.get_node("Special Attack Raycast").get_collider().get_parent().get_node("Health").takeDamage(collector_special_attack.get_node("Special Attack Raycast").get_collider().get_parent(), 10)
				await animation_timer.timeout
				collector_special_attack.get_node("Dev Line").visible = false
			if specialAttack == "tankSpecial":
				animation_timer.start(2)
				velocity.x = move_toward(velocity.x, 0, SPEED*2)
				collector_sprite.visible = false
				tank_sprite.visible = true
				tank_sprite.play("Special Attack")
				await get_tree().create_timer(1).timeout
				shockwave_sprite.visible = true
				shockwave_sprite.play("Shockwave")
				await get_tree().create_timer(0.5).timeout
				tank_special_attack_hurtbox_collision.disabled = false
				await animation_timer.timeout
				tank_special_attack_hurtbox_collision.disabled = true
				shockwave_sprite.visible = false
				tank_sprite.visible = false
				collector_sprite.visible = true
				
	else:
		#Makes character not able to move around in block if it is not the tank's version
		if block != "tankBlock":
			velocity.x = move_toward(velocity.x, 0, SPEED/60)
		#Handles changing character back to normal after block is completed
		if blocking == true:
			if block == "baseBlock":
				#Allows player to change which direction they are blocking from while mid block
				if Input.is_action_just_pressed("Move Left") and facing == true:
					scale.x = abs(scale.x) * -1
					facing = false
				elif Input.is_action_just_pressed("Move Right") and facing == false:
					scale.x = abs(scale.x) * -1
					facing = true
				
				if Input.is_action_just_released("Block"):
					if block_timer.get_time_left() != 0:
						await block_timer.timeout
					collector_sprite.play_backwards("Block")
					animation_timer.paused = false
					blocking = false
			elif block == "tankBlock":
				#Allows player to move while blocking if he is blocking with the tank's block
				if animation_timer.paused == true:
					if direction:
						velocity.x = direction * SPEED
						if velocity.x < 0 and facing == true:
							scale.x = abs(scale.x) * -1
							facing = false
						if velocity.x > 0 and facing == false:
							scale.x = abs(scale.x) * -1
							facing = true
					else:
						velocity.x = move_toward(velocity.x, 0, SPEED)
				elif animation_timer.paused == false:
					velocity.x = move_toward(velocity.x, 0, SPEED/60)
				
				if Input.is_action_just_released("Block"):
					if block_timer.get_time_left() != 0:
						await block_timer.timeout
					print(animation_timer.get_time_left())
					tank_sprite.play("Block")
					animation_timer.paused = false
					blocking = false
					await animation_timer.timeout
					tank_sprite.visible = false
					collector_sprite.visible = true
					
	
	move_and_slide()

#Handles what happens when player takes damage
func got_hit(damage: float):
	if blocking == false:
		collector_sprite.position = Vector2(14, -33)
		animation_timer.paused = false
		animation_timer.start((damage/health.maxHealth)*10)
		collector_sprite.play("Hit",(1*animation_timer.get_time_left()))

#Handles what happens when the player dies (For godot guy, it makes him spin and then grow big)
func death():
	#Only triggers if health is less than or equal to 0 and you aren't already dead
	if health.currentHealth <= 0 and dead == false:
		dead = true
		scale.x = abs(scale.x) * -1
		collector_sprite.play("Dying", 0.25)
		for i in range(hearts_list.size()):
			hearts_list[i].visible = 0
		if Globals.DeveloperMode == true:
			print("Im Dying")
		#for i in range(4):
			#collector_sprite.rotation_degrees += 90
			#await get_tree().create_timer(1).timeout
		#collector_sprite.scale.x = 5
		#collector_sprite.scale.y = 5
		await collector_sprite.animation_finished
		if Globals.DeveloperMode == true:
			print("I Died")
		Engine.time_scale = 0.5
		await get_tree().create_timer(1).timeout
		Engine.time_scale = 1.0
		get_tree().reload_current_scene()

#Adds moveset of the tank after he is defeated and absorbed
func _on_tank_boss_boss_tank_defeated() -> void:
	moveset.append_array(["tankAttack","tankSpecial","tankCounter","tankBlock"])
	basicAttack = moveset[4]
	specialAttack = moveset[5]
	counterAttack = moveset[6]
	block = moveset[7]
