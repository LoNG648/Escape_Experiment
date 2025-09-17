
extends CharacterBody2D

const SPEED = 750.0
const JUMP_VELOCITY = -600.0

@onready var Sprite: Sprite2D = $CharacterSprite
@onready var Hitbox: CollisionShape2D = $Hitbox

var took_damage =false
var can_move = true

func respawn():
	
	self.visible = false
	can_move = false
	await get_tree().create_timer(0.5).timeout
	
	self.global_position = Vector2(0,0)
	self.visible = true
	can_move =true
	
	await get_tree().create_timer(0.5).timeout
	
	took_damage = false


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	#spikes
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		
		if collision.get_collider().name == "tilemapspikes":
			if took_damage == false:
				took_damage =true
				respawn()

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
	
	if can_move == false:
		return
	else:if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	
	move_and_slide()
