class_name player
extends CharacterBody2D

const SPEED = 750.0 #Horizontal Speed
const JUMP_VELOCITY = -600.0 #Jump Height and Speed

@onready var Sprite: AnimatedSprite2D = $Sprite #Sprite Variable
@onready var Collisionbox: CollisionShape2D = $CollisionBox #Collisionbox Variable
@onready var Hitbox: CollisionShape2D = $Hitbox #Hitbox Variable
@onready var health: Node = $Health #Health variable for health system

func _physics_process(delta: float) -> void:
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
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
