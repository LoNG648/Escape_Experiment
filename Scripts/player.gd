class_name player
extends CharacterBody2D

const SPEED = 500.0 #Horizontal Speed
const JUMP_VELOCITY = -600.0 #Jump Height and Speed

var dead: bool = false
var blocking: bool = false
var attacking: bool = false

@onready var sprite: AnimatedSprite2D = $Sprite #Sprite Variable
@onready var collisionbox: CollisionShape2D = $CollisionBox #Collisionbox Variable
@onready var hitbox: CollisionShape2D = $Something/Hitbox
@onready var health: Node = $Health #Health variable for health system
@onready var basicAttackHurtbox: CollisionShape2D = $"Hurtbox/Hurtbox Collision"

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
	
	#Flip the Sprite
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
		if direction > 0:
			sprite.scale.y = 0.5 #Makes crouching change sprite
			sprite.position.y = 25
			collisionbox.scale.y = 0.5 #Makes crouching change collisionbox
			collisionbox.position.y = 25
			hitbox.scale.y = 0.5 #Makes crouching change hitbox
			hitbox.position.y = 25
		if direction < 0:
			sprite.scale.y = -0.5 #Makes crouching change sprite
			sprite.position.y = -25
			collisionbox.scale.y = -0.5 #Makes crouching change collisionbox
			collisionbox.position.y = -25
			hitbox.scale.y = -0.5 #Makes crouching change hitbox
			hitbox.position.y = -25
		
	if Input.is_action_just_released("Crouch"):
		await get_tree().create_timer(5).timeout #Creates a 0.3 second delay
		sprite.scale.y = 1 #Resets sprite back to normal after delay
		sprite.position.y = 0
		collisionbox.scale.y = 1 #Resets collisionbox back to normal after delay
		collisionbox.position.y = 0
		hitbox.scale.y = 1 #Resets hitbox back to normal after delay
		hitbox.position.y = 0
	
	#Apply Attack Mechanic
	if Input.is_action_just_pressed("Basic Attack"):
		if blocking or attacking == true:
			return
		else:
			sprite.rotate(90)
			attacking = true
			basicAttackHurtbox.disabled = false
	
	if Input.is_action_just_released("Basic Attack"):
		basicAttackHurtbox.disabled = true
		get_tree().create_timer(3)
		await get_tree().timer(3).timeout
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
		hitbox.disabled = false
		
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
