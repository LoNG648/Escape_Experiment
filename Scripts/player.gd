class_name Player
extends CharacterBody2D

#Constants
const SPEED = 500.0 #Horizontal Speed
const JUMP_VELOCITY = -600.0 #Jump Height and Speed

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

#Sets counter attack to true if character has blocked damage so they can retaliate back!
func blockedDamage():
	if Globals.DeveloperMode == true:
		print("Nope!")
	counterAttack = true

func _physics_process(delta: float) -> void:
	#Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("Move Left","Move Right")
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Disables code hereafter if dead to not allow player movement and attacks
	if dead:
		return
		
	#Handles jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#Adjust Sprite and Hitbox
	if Input.is_action_just_pressed("Move Left"):
		if facing == true:
			scale.x = abs(scale.x) * -1
			facing = false
	elif Input.is_action_just_pressed("Move Right"):
		if facing == false:
			scale.x = abs(scale.x) * -1
			facing = true
		
	#Play Animations
	if is_on_floor():
		if direction == 0:
			sprite.play("Idle")
		else:
			sprite.play("Run")
	else:
		sprite.play("Jump")
	
	#Applies Horizontal Movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
	
	#Handles crouch and reduces Hitbox
	if Input.is_action_just_pressed("Crouch"):
			scale.y /= 2
	
	#Sets a delay before crouching can be done again and resets hitbox
	if Input.is_action_just_released("Crouch"):
		await get_tree().create_timer(0.3).timeout #Creates a 0.3 second delay
		scale.y *= 2
	
	#Attack and Counterattack Mechanic
	if Input.is_action_just_pressed("Basic Attack") and blocking == false and attacking == false:
			print(counterAttack)
			#Promotes the attack to a counter attack if possible
			if counterAttack == true:
				sprite.play("Counter Attack")
				attacking = true
				counter_attack_hurtbox_collision.disabled = false
				await get_tree().create_timer(0.2).timeout
				counter_attack_hurtbox_collision.disabled = true
				await get_tree().create_timer(2.8).timeout #Counter Attack Delay
				attacking = false
				counterAttack = false
			else:
				#Does a basic attack if can't do a counter attack
				sprite.play("Attack")
				attacking = true
				basic_attack_hurtbox_collision.disabled = false
				await get_tree().create_timer(0.2).timeout
				basic_attack_hurtbox_collision.disabled = true
				await get_tree().create_timer(0.8).timeout #Basic Attack Delay
				attacking = false
	
	#Apply Blocking Mechanic
	if Input.is_action_just_pressed("Block"):
		#Disables blocking if attacking or blocking
		if blocking or attacking == true:
			return
		else:
			sprite.play("Block")
			blocking = true
		
	#Handles changing character back to normal after block is completed
	if Input.is_action_just_released("Block"):
		await get_tree().create_timer(0.3).timeout #Creates a 0.3 second delay
		blocking = false
	
	#Special Attack Mechanic which causes damage to enemy while bypassing the Hurtbox code
	if Input.is_action_just_pressed("Special Attack") and blocking == false and attacking == false:
		if Globals.DeveloperMode == true:
			print("SPECIAL!")
		sprite.play("Special Attack")
		special_attack.get_node("Special Attack Raycast").enabled = true
		if special_attack.get_node("Special Attack Raycast").is_colliding():
			if special_attack.get_node("Special Attack Raycast").get_collider() is Hitbox:
				special_attack.get_node("Special Attack Raycast").get_collider().get_parent().get_node("Health").takeDamage(special_attack.get_node("Special Attack Raycast").get_collider().get_parent(), 10)
		

func got_hit():
	pass

#Handles what happens when the player dies (For godot guy, it makes him spin and then grow big)
func death():
	#Only triggers if health is less than or equal to 0 and you aren't already dead
	if health.currentHealth <= 0 and dead == false:
		dead = true
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
