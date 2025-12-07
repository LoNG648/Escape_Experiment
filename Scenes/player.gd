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
var absorbed: Array = []
var attackMoveset: Array = ["baseAttack"]
var specialMoveset: Array = ["baseSpecial"]
var counterMoveset: Array = ["baseCounter"]
var blockMoveset: Array = ["baseBlock"]
var passiveSet: Array = ["basePassive", "tankPassive", "basicEnemyPassive", "complexEnemyPassive"]
var passive: String = passiveSet[0]
var basicAttack: String = attackMoveset[0]
var specialAttack: String = specialMoveset[0]
var counterAttack: String = counterMoveset[0]
var block: String = blockMoveset[0]

#On Ready Variables
@onready var collector_sprite: AnimatedSprite2D = $CollectorSprite
@onready var tank_sprite: AnimatedSprite2D = $TankSprite
@onready var health: Node = $Health #Health Variable
@onready var tank_special_attack_hurtbox: Hurtbox = $"Tank Special Attack Hurtbox"
@onready var collector_special_attack_hurtbox: Hurtbox = $"Collector Special Attack Hurtbox"
@onready var collector_special_attack_hurtbox_collision: CollisionShape2D = $"Collector Special Attack Hurtbox/Collector Special Attack Hurtbox Collision"
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
@onready var pause_menu: Control = $CanvasLayer/PauseMenu

func _ready() -> void:
	Globals.update_player_position(global_position)
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
		counter_attack_timer.start(5)
		return
	#Sets counter attack to true and starts the counter attack timer if there was not already an opportunity to counter attack
	elif counterAttackStored == false:
		counterAttackStored = true
		counter_attack_timer.start(5)
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
	
	#Handles updates to player Health in real time for the UI
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < (health.currentHealth/10)
	
	#Disables code hereafter if dead to not allow player movement and attacks
	if dead:
		return
	
	if not direction:
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
	
	#Animation code which only runs if no existing animation is running
	if animation_timer.get_time_left() == 0:
		#Resets sprite to its normal position (since other animations have a weird offset)
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
		
		#Attack Mechanic
		if Input.is_action_just_pressed("Basic Attack"):
			#Determines basic attack off of moveset selected and plays respective basic attack
			if basicAttack == "baseAttack":
				#Checks for passive as different passives cause different bonuses
				if passive != "basicEnemyPassive":
					collector_sprite.play("Attack")
					#Sets total lockout time from performing other actions
					animation_timer.start(0.6)
					#Delay before attack actually deals damage. Think of this as a windup duration
					await get_tree().create_timer(0.3).timeout
					collector_basic_attack_hurtbox_collision.disabled = false
					#Length of time attack hitbox is active
					await get_tree().create_timer(0.2).timeout
				#Basic Enemy Passive halves the duration of attacks, thus making them faster
				elif passive == "basicEnemyPassive":
					collector_sprite.play("Attack", 2)
					animation_timer.start(0.3)
					await get_tree().create_timer(0.15).timeout
					collector_basic_attack_hurtbox_collision.disabled = false
					await get_tree().create_timer(0.1).timeout
				collector_basic_attack_hurtbox_collision.disabled = true
				await animation_timer.timeout #Basic Attack Delay
			elif basicAttack == "tankAttack":
				#Hides collector sprite while the character performs the tank's basic attack
				collector_sprite.visible = false
				tank_sprite.visible = true
				if passive != "basicEnemyPassive":
					tank_sprite.play("Attack")
					animation_timer.start(2)
					await get_tree().create_timer(1.5).timeout
					tank_basic_attack_hurtbox_collision.disabled = false
					await get_tree().create_timer(0.5).timeout
				elif passive == "basicEnemyPassive":
					tank_sprite.play("Attack", 2)
					animation_timer.start(1)
					await get_tree().create_timer(0.75).timeout
					tank_basic_attack_hurtbox_collision.disabled = false
					await get_tree().create_timer(0.25).timeout
				tank_basic_attack_hurtbox_collision.disabled = true
				#Reveals collector sprite again and hides tank sprite as the attack is now completed
				collector_sprite.visible = true
				tank_sprite.visible = false
		
		#Apply Blocking Mechanic
		if Input.is_action_just_pressed("Block"):
			#Determines block type from moveset and conducts proper selected block
			if block == "baseBlock":
				#Sets lockout time from performing other actions (Both windup and winddown included here)
				animation_timer.start(1)
				collector_sprite.play("Block")
				#Variable to determine if character is actively blocking to enable delay from releasing block to actually losing its effect
				blocking = true
				#Block Windup length
				block_timer.start(0.5)
				await block_timer.timeout
				#Sets sprite to be constantly set at the full blocking frame for the full duration of the block
				collector_sprite.set_frame_and_progress(2,0)
				collector_sprite.pause()
				#Disables any actions being conducted besides those available during blocks for the full duration of the block
				animation_timer.paused = true
			elif block == "tankBlock":
				#Makes collective sprite invisible for the full duration of the tank's block
				collector_sprite.visible = false
				tank_sprite.visible = true
				animation_timer.start(1)
				tank_sprite.play("Block")
				blocking = true
				block_timer.start(0.5)
				await block_timer.timeout
				tank_sprite.pause()
				animation_timer.paused = true
		
		#Special Attack Mechanic which causes damage to enemy while bypassing the Hurtbox code
		if Input.is_action_just_pressed("Special Attack"):
			#Devmode print testing to confirm special working
			if Globals.DeveloperMode == true:
				print("SPECIAL!")
			#Checks for passive as the complex enemy passive doubles the damage of the special attack
			if passive == "complexEnemyPassive":
				collector_special_attack_hurtbox.damage = 80
				tank_special_attack_hurtbox.damage = 70
			else:
				collector_special_attack_hurtbox.damage = 40
				tank_special_attack_hurtbox.damage = 35
			#Determines which special is active and plays the proper special
			if specialAttack == "baseSpecial":
				collector_sprite.play("Special Attack")
				#Lockout timer from performing any other actions besides crouching
				animation_timer.start(1)
				#Attack windup
				await get_tree().create_timer(0.6).timeout
				collector_special_attack_hurtbox_collision.disabled = false
				#Duration of damage hitbox being active
				await get_tree().create_timer(0.25).timeout
				collector_special_attack_hurtbox_collision.disabled = true
			if specialAttack == "tankSpecial":
				animation_timer.start(2)
				#Makes the character quickly come to a stop while not outright stopping them immediately
				velocity.x = move_toward(velocity.x, 0, SPEED*2)
				#Hides collector sprite for the duration of the tank's special attack
				collector_sprite.visible = false
				tank_sprite.visible = true
				tank_sprite.play("Special Attack")
				await get_tree().create_timer(1).timeout
				#Begins to display the shockwave sprite once the tank sprite slaps the ground
				shockwave_sprite.visible = true
				shockwave_sprite.play("Shockwave")
				#Tank's Special Attack Windup
				await get_tree().create_timer(0.5).timeout
				#Enables the hurtbox so enemies get damaged
				tank_special_attack_hurtbox_collision.disabled = false
				await animation_timer.timeout
				#Disables hurtbox and the tank sprite and shockwave sprite's visibility after the special attack is concluded
				tank_special_attack_hurtbox_collision.disabled = true
				shockwave_sprite.visible = false
				tank_sprite.visible = false
				#Unhides Collector Sprite to allow player to see whatever action they desire executed
				collector_sprite.visible = true
	#Only runs this code if an animation is actively going on
	else:
		#Handles changing character back to normal after block is completed
		if blocking == true:
			#Makes character not able to move around in block if it is not the tank's version
			if block == "baseBlock":
				#Makes character not able to move around in block if it is not the tank's version
				velocity.x = move_toward(velocity.x, 0, SPEED/60)
				#Allows player to change which direction they are blocking from while mid block
				if Input.is_action_just_pressed("Move Left") and facing == true:
					scale.x = abs(scale.x) * -1
					facing = false
				elif Input.is_action_just_pressed("Move Right") and facing == false:
					scale.x = abs(scale.x) * -1
					facing = true
				
				#CounterAttack Mechanic
				if Input.is_action_just_pressed("Basic Attack"):
					if Globals.DeveloperMode == true:
						print(counterAttackStored)
					#Only allows counter attacks to be executed if damage was blocked previously
					if counterAttackStored == true:
						#Checks for active counter attack and executes appropriate selection
						if counterAttack == "baseCounter":
							#Checks for if basic enemy passive is utilized since it reduces the counter attacks animation by half
							if passive != "basicEnemyPassive":
								collector_sprite.play("Counter Attack")
								#Counter attack windup
								await get_tree().create_timer(0.6).timeout
								collector_counter_attack_hurtbox_collision.disabled = false
								#Duration of counter attack being able to damage enemies
								await get_tree().create_timer(0.4).timeout
							elif passive == "basicEnemyPassive":
								collector_sprite.play("Counter Attack",2)
								await get_tree().create_timer(0.3).timeout
								collector_counter_attack_hurtbox_collision.disabled = false
								await get_tree().create_timer(0.2).timeout
							collector_counter_attack_hurtbox_collision.disabled = true
							await collector_sprite.animation_finished
							#Returns sprite back to original blocking animation state after counter attack is concluded
							collector_sprite.play("Block")
							collector_sprite.set_frame_and_progress(2,0)
						elif counterAttack == "tankCounter":
							collector_sprite.visible = false
							tank_sprite.visible = true
							if passive != "basicEnemyPassive":
								tank_sprite.play("Counter Attack")
								await get_tree().create_timer(1).timeout
								tank_counter_attack_hurtbox_collision.disabled = false
								await get_tree().create_timer(0.25).timeout
							elif passive == "basicEnemyPassive":
								tank_sprite.play("Counter Attack", 2)
								await get_tree().create_timer(0.5).timeout
								tank_counter_attack_hurtbox_collision.disabled = false
								await get_tree().create_timer(0.125).timeout
							tank_counter_attack_hurtbox_collision.disabled = true
							#Hides and makes the tank sprite become idle to indicate the tank sprite's counter attack is concluded
							collector_sprite.visible = true
							tank_sprite.visible = false
							tank_sprite.play("Idle")
						#Causes counter attack to be lost after counter attack is concluded, thus requiring additional damage to be blocked before it can be performed again
						counter_attack_timer.start(0.05)
						counterAttackStored = false
					
				if Input.is_action_just_released("Block"):
					#Removes counter attack when a block is intiated to be stopped to prevent a counter attack after no longer blocking
					counter_attack_timer.start(0.05)
					counterAttackStored = false
					#Delays block winddown until after a counterattack is concluded if one is active
					if collector_sprite.animation != "Block":
						await collector_sprite.animation_finished
						await get_tree().create_timer(0.05).timeout
					elif tank_sprite.animation == "Counter Attack":
						await tank_sprite.animation_finished
					#Delays block winddown until after the initial block windup is concluded
					if block_timer.get_time_left() != 0:
						await block_timer.timeout
					#Plays animation backwards, thus looking like the character is unblocking
					collector_sprite.play_backwards("Block")
					animation_timer.paused = false
					#Only when the sprite begins to "unblock" does the blocking effect get removed from the player
					blocking = false
			elif block == "tankBlock":
				#Allows player to move while blocking if he is blocking with the tank's block and is not currently counter attacking
				if collector_sprite.animation != "Counter Attack" and tank_sprite.animation != "Counter Attack":
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
				else:
					#Allows player to flip while counter attacking if so desired
					velocity.x = move_toward(velocity.x, 0, SPEED/60)
					if Input.is_action_just_pressed("Move Left") and facing == true:
						scale.x = abs(scale.x) * -1
						facing = false
					elif Input.is_action_just_pressed("Move Right") and facing == false:
						scale.x = abs(scale.x) * -1
						facing = true
				
				#CounterAttack Mechanic
				if Input.is_action_just_pressed("Basic Attack"):
					if Globals.DeveloperMode == true:
						print(counterAttackStored)
					if counterAttackStored == true:
						if counterAttack == "baseCounter":
							collector_sprite.visible = true
							tank_sprite.visible = false
							if passive != "basicEnemyPassive":
								collector_sprite.play("Counter Attack")
								await get_tree().create_timer(0.6).timeout
								collector_counter_attack_hurtbox_collision.disabled = false
								await get_tree().create_timer(0.4).timeout
							elif passive == "basicEnemyPassive":
								collector_sprite.play("Counter Attack",2)
								await get_tree().create_timer(0.3).timeout
								collector_counter_attack_hurtbox_collision.disabled = false
								await get_tree().create_timer(0.2).timeout
							collector_counter_attack_hurtbox_collision.disabled = true
							await collector_sprite.animation_finished
							collector_sprite.visible = false
							tank_sprite.visible = true
							collector_sprite.play("Idle")
						elif counterAttack == "tankCounter":
							if passive != "basicEnemyPassive":
								tank_sprite.play("Counter Attack")
								await get_tree().create_timer(1).timeout
								tank_counter_attack_hurtbox_collision.disabled = false
								await get_tree().create_timer(0.25).timeout
							elif passive == "basicEnemyPassive":
								tank_sprite.play("Counter Attack", 2)
								await get_tree().create_timer(0.5).timeout
								tank_counter_attack_hurtbox_collision.disabled = false
								await get_tree().create_timer(0.125).timeout
							tank_counter_attack_hurtbox_collision.disabled = true
							tank_sprite.play("Block")
							tank_sprite.set_frame_and_progress(2,0)
						counter_attack_timer.start(0.05)
						counterAttackStored = false
					
				if Input.is_action_just_released("Block"):
					counter_attack_timer.start(0.05)
					counterAttackStored = false
					if tank_sprite.animation != "Block":
						await tank_sprite.animation_finished
						await get_tree().create_timer(0.05).timeout
					elif collector_sprite.animation == "Counter Attack":
						await collector_sprite.animation_finished
					if block_timer.get_time_left() != 0:
						await block_timer.timeout
					tank_sprite.play_backwards("Block")
					animation_timer.paused = false
					blocking = false
					await animation_timer.timeout
					tank_sprite.visible = false
					collector_sprite.visible = true
					
	
	move_and_slide()

#Handles what happens when player takes damage
func got_hit(damage: float):
	if blocking == false:
		#Calculates stun based on percentage of health lost
		var original = damage/health.maxHealth
		var stun = remap(original,0,1,0.5,1.25)
		#Locks player out for the duration of the stun
		animation_timer.paused = false
		animation_timer.start(stun)
		if passive == "tankPassive":
			pass
		else:
			#Disables all in progress attacks to no longer deal damage while stunned
			collector_basic_attack_hurtbox_collision.set_deferred("disabled",true)
			collector_counter_attack_hurtbox_collision.set_deferred("disabled",true)
			collector_special_attack_hurtbox_collision.set_deferred("disabled",true)
			tank_basic_attack_hurtbox_collision.set_deferred("disabled",true)
			tank_special_attack_hurtbox_collision.set_deferred("disabled",true)
			tank_counter_attack_hurtbox_collision.set_deferred("disabled",true)
			#Removes any sprites besides collector since it is the only one with a damaged animation
			tank_sprite.visible = false
			shockwave_sprite.visible = false
			collector_sprite.visible = true
		#Plays the hurt animation for the total duration of the stun
		collector_sprite.play("Hit",(1/animation_timer.get_time_left()))

#Handles what happens when the player dies
func death():
	#Only triggers if health is less than or equal to 0 and you aren't already dead
	if health.currentHealth <= 0 and dead == false:
		dead = true
		#Fixes improper sprite direction
		collector_sprite.flip_h = true
		collector_sprite.play("Dying", 0.5)
		#Halves game speed to indicate how dying is slow painful process
		Engine.time_scale = 0.5
		for i in range(hearts_list.size()):
			hearts_list[i].visible = 0
		#Dev testing print string
		if Globals.DeveloperMode == true:
			print("Im Dying")
		await collector_sprite.animation_finished
		#Another dev test print string to know when death has actually occurred
		if Globals.DeveloperMode == true:
			print("I Died")
		#Causes a 1 second delay (or 2 in this case because of the halved game speed) from death to the level restarting
		await get_tree().create_timer(1).timeout
		#Sets gameplay speed back to normal
		Engine.time_scale = 1.0
		#Reloads current level
		get_tree().reload_current_scene()

#Adds moveset of the tank after he is absorbed
func _on_tank_boss_defeated() -> void:
	attackMoveset.append_array(["tankAttack"])
	specialMoveset.append_array(["tankSpecial"])
	counterMoveset.append_array(["tankCounter"])
	blockMoveset.append_array(["tankBlock"])
	pause_menu.addBossMoveset()
	absorbed.append_array(["Tank_Boss"])

#Adds basic enemy's passive after they are absorbed
func _on_basic_enemy_defeated() -> void:
	pause_menu.addBasicEnemyPassive()
	absorbed.append_array(["Basic_Enemy"])

#Adds complex enemy's passive after they are absorbed
func _on_complex_enemy_defeated() -> void:
	pause_menu.addComplexEnemyPassive()
	absorbed.append_array(["Complex_Enemy"])
