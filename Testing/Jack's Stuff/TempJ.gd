#class_name Player
extends CharacterBody2D

const SPEED = 500.0 #Horizontal Speed
const JUMP_VELOCITY = -600.0 #Jump Height and Speed

var dead: bool = false
var blocking: bool = false
var attacking: bool = false
var specialAttacking: bool = false
var counterAttack: bool = false

var hearts_list : Array[TextureRect]

@onready var sprite: AnimatedSprite2D = $Sprite #Sprite Variable
@onready var health: Node = $Health #Health variable for health system
@onready var special_attack: Node2D = $"Special Attack"
@onready var basic_attack_hurtbox_collision: CollisionShape2D = $"Basic Attack Hurtbox/Basic Attack Hurtbox Collision"
@onready var counter_attack_hurtbox_collision: CollisionShape2D = $"Counter Attack Hurtbox/Counter Attack Hurtbox Collision"

func _ready() -> void:
	var hearts_parents = $HealthUI/HBoxContainer
	for child in hearts_parents.get_children():
		hearts_list.append(child)
		print(hearts_list)

func blockedDamage():
	print("Nope!")
	counterAttack = true

func _physics_process(delta: float) -> void:
	#Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("Move Left","Move Right")
	
	if dead:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	#Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#Adjust Sprite and everything
	if Input.is_action_just_pressed("Move Left"):
		scale.x = abs(scale.x) * -1
	elif Input.is_action_just_pressed("Move Right"):
		scale.x = abs(scale.x) * 1
		
	#Play Animations
	if is_on_floor():
		if direction == 0:
			sprite.play("Idle")
		else:
			sprite.play("Run")
	else:
		sprite.play("Jump")
	
	#Apply Movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
	
	#Handles crouch
	if Input.is_action_just_pressed("Crouch"):
		if direction >= 0:
			scale.y /= 2
		if direction < 0:
			scale.y /= 2
	
	if Input.is_action_just_released("Crouch"):
		await get_tree().create_timer(0.3).timeout #Creates a 0.3 second delay
		scale.y *= 2
	
	#Apply Attack Mechanic
	if Input.is_action_just_pressed("Basic Attack") and blocking == false and attacking == false:
			print(counterAttack)
			if counterAttack == true:
				sprite.play("Counter Attack")
				attacking = true
				counter_attack_hurtbox_collision.disabled = false
				await get_tree().create_timer(0.2).timeout
				counter_attack_hurtbox_collision.disabled = true
				await get_tree().create_timer(2.8).timeout
				attacking = false
				counterAttack = false
			else:
				sprite.play("Attack")
				attacking = true
				basic_attack_hurtbox_collision.disabled = false
				await get_tree().create_timer(0.2).timeout
				basic_attack_hurtbox_collision.disabled = true
				await get_tree().create_timer(0.8).timeout
				attacking = false
	
	#Apply Blocking Mechanic
	if Input.is_action_just_pressed("Block"):
		if blocking or attacking == true:
			return
		else:
			sprite.play("Block")
			blocking = true
		
	if Input.is_action_just_released("Block"):
		await get_tree().create_timer(0.3).timeout #Creates a 0.3 second delay
		blocking = false
		
	if Input.is_action_just_pressed("Special Attack") and blocking == false and attacking == false:
		print("SPECIAL!")
		sprite.play("Special Attack")
		special_attack.get_node("Special Attack Raycast").enabled = true
		if special_attack.get_node("Special Attack Raycast").is_colliding():
			if special_attack.get_node("Special Attack Raycast").get_collider().health:
				special_attack.get_node("Special Attack Raycast").get_collider().get_node("Health").takeDamage(special_attack.get_node("Special Attack Raycast").get_collider(), 10)
		

func got_hit(currentHealth: float):
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i < (currentHealth/20)

func death():
	if health.currentHealth <= 0 and dead == false:
		dead = true
		for i in range(hearts_list.size()):
			hearts_list[i].visible = 0
		print("Im Dying")
		for i in range(4):
			sprite.rotation_degrees += 90
			await get_tree().create_timer(1).timeout
		sprite.scale.x = 5
		sprite.scale.y = 5
		print("I Died")
		Engine.time_scale = 0.5
		await get_tree().create_timer(1).timeout
		Engine.time_scale = 1.0
		get_tree().reload_current_scene()
