class_name basic_enemy
extends CharacterBody2D

var speed = 250.0
var held_speed = 250

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var facing_right = true
var windup = false
var attacking = false
#signal in_attack(bool)

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
	
	if windup == false and attacking == false:
		$AnimatedSprite2D.play("run")
	
	
		
		
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
	if windup == true:
		attacking = true
		#emit_signal("in_attack", true)
		animation_player.play("attack1")
		get_node("Hurtbox/hurtboxcollision").disabled = false
		windup = false
	elif attacking == true:
		attacking = false
		get_node("Hurtbox/hurtboxcollision").disabled = true
		speed = held_speed
	else:
		pass


func _on_detect_player_body_entered(body: Node2D) -> void:
	if body is player:
		windup = true
		#emit_signal("in_attack", true)
		speed = 0
		animation_player.play("windup1")
	else:
		pass
