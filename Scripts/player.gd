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
var counterAttack: bool = false #Does character have a counter attack?
var facing: bool = true #Which direction is the character facing (left is false, right is true)

#On Ready Variables
@onready var sprite: AnimatedSprite2D = $Sprite #Sprite Variable
@onready var health: Node = $Health #Health Variable
@onready var special_attack: Node2D = $"Special Attack" #Special Attack Variable
@onready var basic_attack_hurtbox_collision: CollisionShape2D = $"Basic Attack Hurtbox/Basic Attack Hurtbox Collision" #Basic Attack Hurtbox
@onready var counter_attack_hurtbox_collision: CollisionShape2D = $"Counter Attack Hurtbox/Counter Attack Hurtbox Collision" #Counter Attack Hurtbox
@onready var crouch_timer: Timer = $"Timers/Crouch Timer"
@onready var counter_attack_timer: Timer = $"Timers/Counter Attack Timer"
@onready var block_timer: Timer = $"Timers/Block Timer"
@onready var animation_timer: Timer = $"Timers/Animation Timer"


#Sets counter attack to true if character has blocked damage so they can retaliate back!
func blockedDamage():
	if Globals.DeveloperMode == true:
		print("Nope!")
	counterAttack = true
	counter_attack_timer.start()
	await counter_attack_timer.timeout
	if Globals.DeveloperMode == true:
		print("Counter Attack Lost")
	counterAttack = false

func _physics_process(delta: float) -> void:
	#Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("Move Left","Move Right")
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Disables code hereafter if dead to not allow player movement and attacks
	if dead:
		return
	
	if animation_timer.get_time_left() == 0:
		sprite.position = Vector2(0, -42)
		if is_on_floor():
			if direction == 0:
				sprite.play("Idle")
			else:
				sprite.play("Run")
		else:
			sprite.play("Jump")
		
		#Handles jump
		if Input.is_action_just_pressed("Jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		#Applies Horizontal Movement
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
		
		#Handles crouch and reduces Hitbox
		if Input.is_action_just_pressed("Crouch"):
			if crouch_timer.get_time_left() == 0:
				scale.y /= 2
			crouch_timer.paused = true
		
		#Sets a delay before crouching can be done again and resets hitbox
		if Input.is_action_just_released("Crouch"):
			if crouch_timer.get_time_left() != 0:
				crouch_timer.paused = false
				crouch_timer.start()
				return
			elif crouch_timer.get_time_left() == 0:
				crouch_timer.paused = false
				crouch_timer.start()
			await crouch_timer.timeout
			scale.y *= 2
		
		#Attack and Counterattack Mechanic
		if Input.is_action_just_pressed("Basic Attack"):
			print(counterAttack)
			#Promotes the attack to a counter attack if possible
			if counterAttack == true:
				sprite.position = Vector2(14, -33)
				sprite.play("Counter Attack")
				attacking = true
				animation_timer.start(2)
				counter_attack_hurtbox_collision.disabled = false
				await get_tree().create_timer(0.2).timeout
				counter_attack_hurtbox_collision.disabled = true
				await animation_timer.timeout
				attacking = false
				counterAttack = false
			else:
				#Does a basic attack if can't do a counter attack
				sprite.position = Vector2(14, -33)
				sprite.play("Attack")
				animation_timer.start(1)
				attacking = true
				basic_attack_hurtbox_collision.disabled = false
				await get_tree().create_timer(0.2).timeout
				basic_attack_hurtbox_collision.disabled = true
				await animation_timer.timeout #Basic Attack Delay
				attacking = false
		
		#Apply Blocking Mechanic
		if Input.is_action_just_pressed("Block"):
			sprite.position = Vector2(14, -33)
			animation_timer.start(0.5)
			sprite.play("Block")
			blocking = true
			block_timer.start()
			await block_timer.timeout
			sprite.pause()
			animation_timer.paused = true
		
		#Special Attack Mechanic which causes damage to enemy while bypassing the Hurtbox code
		if Input.is_action_just_pressed("Special Attack"):
			if Globals.DeveloperMode == true:
				print("SPECIAL!")
			sprite.position = Vector2(14, -33)
			sprite.play("Special Attack")
			special_attack.get_node("Dev Line").visible = true
			animation_timer.start(0.25)
			special_attack.get_node("Special Attack Raycast").enabled = true
			if special_attack.get_node("Special Attack Raycast").is_colliding():
				if special_attack.get_node("Special Attack Raycast").get_collider() is Hitbox:
					special_attack.get_node("Special Attack Raycast").get_collider().get_parent().get_node("Health").takeDamage(special_attack.get_node("Special Attack Raycast").get_collider().get_parent(), 10)
			await animation_timer.timeout
			if Globals.DeveloperMode == false:
				special_attack.get_node("Dev Line").visible = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED/60)
		#Handles changing character back to normal after block is completed
		if blocking == true:
			if Input.is_action_just_pressed("Move Left") and facing == true:
				scale.x = abs(scale.x) * -1
				facing = false
			elif Input.is_action_just_pressed("Move Right") and facing == false:
				scale.x = abs(scale.x) * -1
				facing = true
				
			if Input.is_action_just_released("Block"):
				if block_timer.get_time_left() != 0:
					await block_timer.timeout
				sprite.play("Block")
				animation_timer.paused = false
				blocking = false
	
	move_and_slide()
	
func got_hit():
	pass

#Handles what happens when the player dies (For godot guy, it makes him spin and then grow big)
func death():
	#Only triggers if health is less than or equal to 0 and you aren't already dead
	if health.currentHealth <= 0 and dead == false:
		dead = true
		sprite.play("Dying")
		if Globals.DeveloperMode == true:
			print("Im Dying")
		for i in range(4):
			sprite.rotation_degrees += 90
			await get_tree().create_timer(1).timeout
		sprite.scale.x = 5
		sprite.scale.y = 5
		if Globals.DeveloperMode == true:
			print("I Died")
		Engine.time_scale = 0.5
		await get_tree().create_timer(1).timeout
		Engine.time_scale = 1.0
		get_tree().reload_current_scene()
