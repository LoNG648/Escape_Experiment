class_name Complex_Enemy
extends CharacterBody2D

var speed = -125.0
var held_speed = -125
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dead: bool = false
var facing_left = true
var windup = false
var attacking = false
var holster = false
var player_in_reach = false
var blocking = false
var hit = false
var multi_hit = false
var waiting = false

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
		
	velocity.x = speed
		
	if windup == false and attacking == false and holster == false and dead == false and player_in_reach == false and hit == false:
		sprite.play("run")
	elif waiting == true:
		sprite.play("idle")
	
	
		
		
	move_and_slide()

func flip():
	facing_left = !facing_left
	scale.x = abs(scale.x) * -1
	if facing_left:
		speed = abs(speed) * -1
		held_speed = abs(held_speed) * -1
	else:
		speed = abs(speed)
		held_speed = abs(held_speed)
		
#func take_damage(amount: int) -> void:
	#$AnimatedSprite2D.play("hit")
	#print("Damage: ", amount)
 


func _on_animated_sprite_2d_animation_finished() -> void:
	if dead == true:
		queue_free()
		print("Complex enemy dead")
	elif hit == true:
		hit = false
		if player_in_reach == true and dead == false:
			hitbox_collision.disabled = false
			_player_still_in_reach()
		else:
			speed = held_speed
			hitbox_collision.disabled = false
	elif windup == true and dead == false:
		attacking = true
		sprite.play("1attack")
		hurtbox_collision.disabled = false
		windup = false
	elif attacking == true and dead == false:
		attacking = false
		hurtbox_collision.disabled = true
		sprite.play("1holster")
		holster = true
	elif holster == true and dead == false:
		waiting = true
		await get_tree().create_timer(0.65).timeout
		waiting = false
		holster = false
		if player_in_reach == true:
			_player_still_in_reach()
		else:
			speed = held_speed
	else:
		pass
		

func _on_detect_player_body_entered(body: Node2D) -> void:
	if body is Player and dead == false:
		player_in_reach = true
		windup = true
		speed = 0
		sprite.play("1windup")
	else:
		pass
		
func _player_still_in_reach():
	if dead == false:
		windup = true
		multi_hit = true
		#await get_tree().create_timer(0.6).timeout
		speed = 0
		sprite.play("1windup")


func _on_detect_player_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_reach = false
		multi_hit = false

func got_hit():
	hit = true
	hitbox_collision.disabled = true
	windup = false
	attacking = false
	holster = false
	speed = 0
	sprite.play("hit")
#need a hitbox that is separate from the collisionbox so that i can disable it while playing the hit animation
#also need to ask Ryan what collision layer the attacks are on for said hitbox

func death():
	speed = 0
	if health.currentHealth <= 0:
		dead = true
		windup = false
		attacking = false
		holster = false
		player_in_reach = false
		print("Complex enemy dying")
		sprite.play("death")
