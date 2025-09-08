class_name player
extends CharacterBody2D

const SPEED = 750.0
const JUMP_VELOCITY = -600.0

@onready var Sprite: Sprite2D = $CharacterSprite
@onready var Hitbox: CollisionShape2D = $Hitbox

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	#Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	#Handles crouch
	if Input.is_action_just_pressed("Crouch"):
		Sprite.scale.y = 0.5
		Sprite.position.y = 25
	if Input.is_action_just_released("Crouch"):
		get_tree().create_timer(0.3)
		await get_tree().create_timer(0.3).timeout
		Sprite.scale.y = 1
		Sprite.position.y = 0.0
	#Get the input direction and handle the movement/deceleration
	var direction := Input.get_axis("Move Left","Move Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
