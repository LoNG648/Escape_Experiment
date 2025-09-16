class_name player
extends CharacterBody2D

const SPEED = 750.0 #Horizontal Speed
const JUMP_VELOCITY = -600.0 #Jump Height and Speed

var dead: bool = false
var block: bool = false

@onready var Sprite: AnimatedSprite2D = $Sprite #Sprite Variable
@onready var Collisionbox: CollisionShape2D = $CollisionBox #Collisionbox Variable
@onready var Hitbox: CollisionShape2D = $Hitbox #Hitbox Variable
@onready var health: Node = $Health #Health variable for health system

func _physics_process(delta: float) -> void:
	if dead:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	#Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#Handles crouch
	if Input.is_action_just_pressed("Crouch"):
		Sprite.scale.y = 0.5 #Makes crouching change sprite
		Sprite.position.y = 25
		Collisionbox.scale.y = 0.5 #Makes crouching change collisionbox
		Collisionbox.position.y = 25
		Hitbox.scale.y = 0.5 #Makes crouching change hitbox
		Hitbox.position.y = 25
		
	if Input.is_action_just_released("Crouch"):
		await get_tree().create_timer(0.3).timeout #Creates a 0.3 second delay
		Sprite.scale.y = 1 #Resets sprite back to normal after delay
		Sprite.position.y = 0
		Collisionbox.scale.y = 1 #Resets collisionbox back to normal after delay
		Collisionbox.position.y = 0
		Hitbox.scale.y = 1 #Resets hitbox back to normal after delay
		Hitbox.position.y = 0
	
	#Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("Move Left","Move Right")
	
	#Flip the Sprite
	if direction > 0:
		Sprite.flip_h = false
	elif direction < 0:
		Sprite.flip_h = true
		
	#Play Animations
	if is_on_floor():
		if direction == 0:
			Sprite.play("Idle")
		else:
			Sprite.play("Run")
	else:
		Sprite.play("Jump")
	
	#Apply Movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()
	
	#Apply Blocking Mechanic
	if Input.is_action_just_pressed("Block"):
		block = true
		
	if Input.is_action_just_released("Block"):
		await get_tree().create_timer(0.3).timeout #Creates a 0.3 second delay
		block = false
		
func death():
	if health.currentHealth <= 0:
		dead = true
		print("Im Dying")
		for i in range(4):
			Sprite.rotation_degrees += 90
			await get_tree().create_timer(1).timeout
		Sprite.scale.x = 5
		Sprite.scale.y = 5
		print("I Died")
		Engine.time_scale = 0.5
		await get_tree().create_timer(1).timeout
		Engine.time_scale = 1.0
		get_tree().reload_current_scene()
