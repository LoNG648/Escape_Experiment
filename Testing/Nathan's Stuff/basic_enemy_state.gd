extends CharacterBody2D
class_name Basic_Enemy2

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	move_and_slide()
	
	if velocity.length() > 0:
		$Sprite.play("run")
	
	if velocity.x > 0:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
