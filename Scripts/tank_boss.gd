class_name Tank_Boss
extends CharacterBody2D

var speed = -60
var held_speed = -60
var flipping_speed = 0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dead: bool = false
var facing_left = true
var directions : Vector2
var windup = false
var attacking = false
var player_in_reach = false
var player_in_special_reach = false
var player_behind = false
var blocking = false
var hit = false
var is_chasing = false
var knockback = 200
var is_roaming = true
var flipping = false
var waiting = false
var special_windup = false
var special_attacking = false
var special_holster = false
var special_waiting = false

var player_in_area = false
#signal in_attack(bool)

@onready var health: Node = $Health #Health variable for health system
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var floor_raycast: RayCast2D = $"Floor Raycast"
@onready var wall_raycast: RayCast2D = $"Wall Raycast"
@onready var hurtbox_collision: CollisionShape2D = $"Hurtbox/Hurtbox Collision"
@onready var hitbox_collision: CollisionShape2D = $"Hitbox/Hitbox Collision"
@onready var collision: CollisionShape2D = $CollisionBox
@onready var special_collision = $"HurtboxSpecial/Hurtbox Special Collision"
@onready var special_sprite: AnimatedSprite2D = $GroundThing

#@export var wander_direction : Node2D

signal bossTankDefeated

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
	#if attacking == true:
		#hurtbox_collision.disabled = false
		
	move(delta)
	
	if windup == false and attacking == false and dead == false and hit == false and flipping == false and player_in_reach == false and special_windup == false and special_attacking == false and special_holster == false:
		sprite.play("walk")
	elif waiting == true:
		sprite.play("idle")
	
	#velocity = wander_direction.direction * speed * -1
	move_and_slide()
	
	if dead == true and is_roaming == true:
		is_roaming = false

func flip():
	flipping = true
	facing_left = !facing_left
	scale.x = abs(scale.x) * -1
	if facing_left:
		speed = abs(speed) * -1
		held_speed = abs(held_speed) * -1
	else:
		speed = abs(speed)
		held_speed = abs(held_speed)
	#await get_tree().create_timer(choose([0.2,0.4,0.6])).timeout
	flipping = false
	if player_behind == true:
		player_behind = false
		player_in_reach = true
		_player_still_in_reach()
	$DirectionTimer.wait_time = choose([3,3.5,4])
		
#func take_damage(amount: int) -> void:
	#animation_player.play("hit")
	#print("Damage: ", amount)

func _on_animated_sprite_2d_animation_finished() -> void:
	if hit == true:
		hit = false
		if player_in_reach == true and dead == false:
			_player_still_in_reach()
			hitbox_collision.disabled = true
		elif player_in_special_reach == true and dead == false:
			_player_still_in_special_reach()
			special_collision.disabled = true
		elif dead == true:
			pass
		else:
			speed = held_speed
			hitbox_collision.disabled = false
		#collision.disabled = false
	elif dead == true:
		queue_free()
		print("Boss dead")
	elif windup == true and dead == false:
		special_attacking = false
		special_holster = false
		special_windup = false
		attacking = true
		sprite.play("attack1")
		hurtbox_collision.disabled = false
		windup = false
	elif attacking == true and dead == false:
		special_attacking = false
		special_holster = false
		special_windup = false
		waiting = true
		hurtbox_collision.disabled = true
		await get_tree().create_timer(0.2).timeout
		waiting = false
		attacking = false
		if player_in_reach == true:
			_player_still_in_reach()
		else:
			speed = held_speed
	elif special_windup == true and dead == false and attacking == false:
		special_attacking = true
		sprite.play("special attack")
		special_sprite.show()
		special_sprite.play("default")
		#await get_tree().create_timer(0.2).timeout
		special_collision.disabled = false
		await special_sprite.animation_finished
		special_collision.disabled = true
		special_sprite.hide()
		special_windup = false
	elif special_attacking == true and dead == false:
		special_holster = true
		sprite.play("special holster")
		special_attacking = false
	elif special_holster == true and dead == false and attacking == false:
		special_holster == false
		special_waiting = true
		await get_tree().create_timer(1.0).timeout
		special_waiting = false
		if player_in_special_reach == true:
			_player_still_in_special_reach()
		else:
			speed = held_speed
	else:
		pass

func move(_delta):
	if dead == false:
		if is_chasing == false and flipping == false and windup == false and attacking == false and hit == false and player_in_reach == false and special_attacking == false and special_holster == false and special_windup == false and player_in_special_reach == false:
			speed = held_speed
			velocity.x = speed
		#elif is_chasing == true and hit == false and windup == false and attacking == false:
			#var direction_to_player = position.direction_to(player.position) * speed
			#velocity.x = direction_to_player.x
		elif flipping == true:
			velocity.x = flipping_speed
		elif player_in_reach == true:
			velocity.x = flipping_speed
		elif player_in_special_reach == true:
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

func _on_detect_special_player_body_entered(body: Node2D) -> void:
	if body is Player and dead == false and special_waiting == false and special_windup == false:
		player_in_special_reach = true
		special_windup = true
		speed = 0
		sprite.play("special windup")
	else:
		pass

func _on_detect_special_player_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_special_reach = false
 
func _player_still_in_reach():
	if player_in_reach == true:
		player_behind = false
		windup = true
		speed = 0
		sprite.play("windup1")

func _player_still_in_special_reach():
	if player_in_special_reach == true and special_waiting == false:
		special_windup = true
		speed = 0
		sprite.play("special windup")
	elif special_waiting == true:
		_player_still_in_special_reach()

func got_hit(_damage: float):
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
		bossTankDefeated.emit()

func _on_direction_timer_timeout() -> void:
	if !is_chasing:
		directions = choose([Vector2.RIGHT, Vector2.LEFT])
		if facing_left == true and directions == Vector2.RIGHT and windup == false and attacking == false and special_attacking == false and special_holster == false and special_windup == false:
			flip()
		elif facing_left == false and directions == Vector2.LEFT and windup == false and attacking == false and special_attacking == false and special_holster == false and special_windup == false:
			flip()
		if windup == true and attacking == true and special_attacking == true and special_holster == true and special_windup == true:
			flipping = false


func choose(array):
	array.shuffle()
	return array.front()


func _on_behind_detection_box_body_entered(body: Node2D) -> void:
	if body is Player and dead == false:
		player_behind = true


func _on_behind_detection_box_body_exited(body: Node2D) -> void:
	if body is Player:
		player_behind = false
