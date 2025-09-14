extends CharacterBody2D

var speed = 250.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var facing_right = true
var windup = false
var attacking = false

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
	$AnimatedSprite2D.play("run")
	
	
		
		
	move_and_slide()

func flip():
	facing_right = !facing_right
	scale.x = abs(scale.x) * -1
	if facing_right:
		speed = abs(speed)
	else:
		speed = abs(speed) * -1
		
func take_damage(amount: int) -> void:
	$AnimatedSprite2D.play("hit")
	#print("Damage: ", amount)




func _on_animated_sprite_2d_animation_finished() -> void:
	if attacking == true:
		attacking = false
		get_node("Hurtbox/hurtboxcollision").disabled = true
	else:
		pass
		
	if windup == true:
		attacking = true
		$AnimatedSprite2D.play("attack1")
		get_node("Hurtbox/hurtboxcollision").disabled = false
		windup = false
	else:
		pass


func _on_detect_player_body_entered(body: Node2D) -> void:
	if body is player:
		velocity.x = 0
		$AnimatedSprite2D.play("windup1")
		windup = true
	else:
		pass
