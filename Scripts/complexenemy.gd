extends CharacterBody2D

var speed = -125.0
var held_speed = -125

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var facing_left = true
var windup = false
var attacking = false
var holster = false
var player_in_reach = false

@onready var animation_player := $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
		
	if !$RayCast2DFloor.is_colliding() && is_on_floor():
		flip()
	
	if $RayCast2DWall.is_colliding() && is_on_floor():
		flip()
	
	velocity.x = speed
	if windup == false and attacking == false and holster == false:
			$AnimatedSprite2D.play("run")
	
	
		
		
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
	if windup == true:
		attacking = true
		animation_player.play("1attack")
		get_node("Hurtbox/hurtboxcollision").disabled = false
		windup = false
	elif attacking == true:
		attacking = false
		get_node("Hurtbox/hurtboxcollision").disabled = true
		animation_player.play("1holster")
		holster = true
	elif holster == true:
		holster = false
		if player_in_reach == true:
			_player_still_in_reach()
		else:
			speed = held_speed
	else:
		pass
		

func _on_detect_player_body_entered(body: Node2D) -> void:
	if body is player:
		windup = true
		speed = 0
		animation_player.play("1windup")
	else:
		pass
		
func _player_still_in_reach():
	windup = true
	speed = 0
	animation_player.play("1windup")


func _on_detect_player_body_exited(body: Node2D) -> void:
	if body is player:
		player_in_reach = false
