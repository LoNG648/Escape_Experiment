class_name Basic_Enemy
extends CharacterBody2D

var speed = 200.0
var held_speed = 200
var flipping_speed = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dead: bool = false
var facing_right = true
var directions : Vector2
var windup = false
var attacking = false
var player_in_reach = false
var player_behind = false
var blocking = false
var hit = false
var is_chasing = false
var knockback = 200
var is_roaming = true
var flipping = false

var player_in_area = false
#signal in_attack(bool)

@onready var health: Node = $Health #Health variable for health system
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var floor_raycast: RayCast2D = $"Floor Raycast"
@onready var wall_raycast: RayCast2D = $"Wall Raycast"
@onready var hurtbox_collision: CollisionShape2D = $"Hurtbox/Hurtbox Collision"
@onready var hitbox_collision: CollisionShape2D = $"Hitbox/Hitbox Collision"


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if !floor_raycast.is_colliding() && is_on_floor():
		flip()
	
	if wall_raycast.is_colliding() && is_on_floor():
		flip()
	
	#if flipping == true:
		#$DirectionTimer.start(choose([2.0,2.5,3]))
		
		
	move(delta)
	
	if windup == false and attacking == false and dead == false and hit == false and flipping == false and player_in_reach == false:
		sprite.play("run")
	elif flipping == true:
		sprite.play("idle")
	
	#velocity = wander_direction.direction * speed * -1
	move_and_slide()
	
	if dead == true and is_roaming == true:
		is_roaming = false

func flip():
	flipping = true
	facing_right = !facing_right
	scale.x = abs(scale.x) * -1
	if facing_right:
		speed = abs(speed)
		held_speed = abs(held_speed)
	else:
		speed = abs(speed) * -1
		held_speed = abs(held_speed) * -1
	#await get_tree().create_timer(choose([0.1,0.3,0.5])).timeout
	flipping = false
	if player_behind == true:
		#flipping = false
		player_behind = false
		player_in_reach = true
		_player_still_in_reach()
	#elif player_behind == false:
		#await get_tree().create_timer(choose([0.1,0.3,0.5])).timeout
		#flipping = false
	$DirectionTimer.wait_time = choose([2.0,2.5,3])
		
#func take_damage(amount: int) -> void:
	#animation_player.play("hit")
	#print("Damage: ", amount)

func _on_animated_sprite_2d_animation_finished() -> void:
	if hit == true:
		hit = false
		if player_in_reach == true and dead == false:
			_player_still_in_reach()
			hitbox_collision.disabled = false
		elif dead == true:
			pass
		else:
			speed = held_speed
			hitbox_collision.disabled = false
		#collision.disabled = false
	elif dead == true:
		queue_free()
		print("Basic enemy dead")
	elif windup == true:
		attacking = true
		sprite.play("attack1")
		hurtbox_collision.disabled = false
		windup = false
	elif attacking == true:
		attacking = false
		hurtbox_collision.disabled = true
		if player_in_reach == true:
			_player_still_in_reach()
		else:
			speed = held_speed
	else:
		pass

func move(_delta):
	if dead == false:
		if is_chasing == false and flipping == false and windup == false and attacking == false and hit == false and player_in_reach == false:
			speed = held_speed
			velocity.x = speed
		#elif is_chasing == true and hit == false and windup == false and attacking == false:
			#var direction_to_player = position.direction_to(player.position) * speed
			#velocity.x = direction_to_player.x
		elif flipping == true:
			velocity.x = flipping_speed
		elif player_in_reach == true:
			velocity.x = flipping_speed
		is_roaming = true
	elif dead == true:
		velocity.x = 0

func _on_detect_player_body_entered(body: Node2D) -> void:
	if body is Player and dead == false:
		player_in_reach = true
		windup = true
		speed = 0
		sprite.play("windup1")
	else:
		pass

func _on_detect_player_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_reach = false
		
 
func _player_still_in_reach():
	player_behind = false
	windup = true
	speed = 0
	sprite.play("windup1")

func got_hit():
	hit = true
	hitbox_collision.disabled = true
	print("Basic enemy hitbox disabled!")
	windup = false
	attacking = false
	speed = 0
	sprite.play("hit")
#need a hitbox that is separate from the collisionbox so that i can disable it while playing the hit animation
#also need to ask Ryan what collision layer the attacks are on for said hitbox

func death():
	speed = 0
	if health.currentHealth <= 0:
		dead = true
		windup = false
		player_in_reach = false
		player_behind = false
		print("Basic enemy dying")
		sprite.play("death")

func _on_direction_timer_timeout() -> void:
	#$DirectionTimer.wait_time = choose([2.0,2.5,3])
	if !is_chasing and dead == false:
		directions = choose([Vector2.RIGHT, Vector2.LEFT])
		if facing_right == true and directions == Vector2.LEFT:
			flip()
		elif facing_right == false and directions == Vector2.RIGHT:
			flip()

func choose(array):
	array.shuffle()
	return array.front()


func _on_behind_detection_box_body_entered(body: Node2D) -> void:
	if body is Player and dead == false:
		player_behind = true
		

func _on_behind_detection_box_body_exited(body: Node2D) -> void:
	if body is Player:
		player_behind = false
