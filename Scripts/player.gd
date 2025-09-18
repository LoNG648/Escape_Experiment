class_name player
extends CharacterBody2D

const SPEED = 500.0 #Horizontal Speed
const JUMP_VELOCITY = -600.0 #Jump Height and Speed

var dead: bool = false
var blocking: bool = false
var attacking: bool = false
var specialAttacking: bool = false

@onready var sprite: AnimatedSprite2D = $Sprite #Sprite Variable
@onready var collisionbox: CollisionShape2D = $CollisionBox #Collisionbox Variable
@onready var hitbox_collision: CollisionShape2D = $"Hitbox/Hitbox Collision"
@onready var health: Node = $Health #Health variable for health system
@onready var basicAttackHurtbox: CollisionShape2D = $"Hurtbox/Hurtbox Collision"
@onready var bullet_trajectory: RayCast2D = $BulletTrajectory

func _physics_process(delta: float) -> void:
	if dead:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	#Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("Move Left","Move Right")
		
	#Adjust Sprite and everything
	if direction > 0:
		scale.x = abs(scale.x) * 1
	elif direction < 0:
		scale.x = abs(scale.x) * -1
		
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
			sprite.play("Attack")
			attacking = true
			basicAttackHurtbox.disabled = false
			await get_tree().create_timer(0.2).timeout
			basicAttackHurtbox.disabled = true
			await get_tree().create_timer(4.8).timeout
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
		specialAttacking = true
		while specialAttacking == true:
			sprite.play("Special Attack")
			bullet_trajectory.enabled = true
			if bullet_trajectory.is_colliding():
				print(bullet_trajectory.get_collider())
		
func death():
	if health.currentHealth <= 0 and dead == false:
		dead = true
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
