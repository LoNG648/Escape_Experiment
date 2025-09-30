class_name Basic_Enemy
extends CharacterBody2D

var speed = 250.0
var held_speed = 250
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var dead: bool = false
var facing_right = true
var windup = false
var attacking = false
var player_in_reach = false
var blocking = false
var hit = false
#signal in_attack(bool)

@onready var health: Node = $Health #Health variable for health system
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var floor_raycast: RayCast2D = $"Floor Raycast"
@onready var wall_raycast: RayCast2D = $"Wall Raycast"
@onready var hurtbox_collision: CollisionShape2D = $"Hurtbox/Hurtbox Collision"
@onready var hitbox_collision: CollisionShape2D = $"Hitbox/Hitbox Collision"
@onready var collision: CollisionShape2D = $Collisionbox

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
	if !floor_raycast.is_colliding() && is_on_floor():
		flip()
	
	if wall_raycast.is_colliding() && is_on_floor():
		flip()
	
	
	velocity.x = speed
	
	if windup == false and attacking == false and dead == false and hit == false:
		sprite.play("run")
	
	
	move_and_slide()

func flip():
	facing_right = !facing_right
	scale.x = abs(scale.x) * -1
	if facing_right:
		speed = abs(speed)
		held_speed = abs(held_speed)
	else:
		speed = abs(speed) * -1
		held_speed = abs(held_speed) * -1
		
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
		print("Basic enemy dying")
		sprite.play("death")
