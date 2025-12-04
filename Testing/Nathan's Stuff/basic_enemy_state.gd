extends CharacterBody2D
class_name Basic_Enemy2

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_left = false
var facing_right = true
var blocking = false
var flip = false

@onready var detection_box = $"Detectionbox/Detectionbox Collision"
@onready var hurtbox_collision = $"Hurtbox/Hurtbox Collision"
@onready var collision = $Collisionbox
@onready var floor_raycast = $"Floor Raycast"
@onready var wall_raycast = $"Wall Raycast"
@onready var hitbox_collision = $"Hitbox/Hitbox Collision"

@onready var state_machine = $"State Machine"

func _ready() -> void:
	#for child in state_machine.get_children():
		#if child is State:
			#state_machine.states[child.name.to_lower()] = child
			#child.Transitioned.connect(got_hit)
			#child.Transitioned.connect(death)
	pass

func _physics_process(delta):
	var distance = global_position.x
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	move_and_slide()
	
	
	if velocity.x > 0:
		$Sprite.flip_h = false
	elif velocity.x < 0:
		$Sprite.flip_h = true
	if velocity.x != 0:
		hurtbox_collision.position.x = abs(hurtbox_collision.position.x) * signf(velocity.x)
		detection_box.position.x = abs(detection_box.position.x) * signf(velocity.x)
		hitbox_collision.position.x = abs(hitbox_collision.position.x) * signf(velocity.x)
		wall_raycast.position.x = abs(wall_raycast.position.x) * signf(velocity.x)
		floor_raycast.position.x = abs(floor_raycast.position.x) * signf(velocity.x)
		collision.position.x = abs(collision.position.x) * signf(velocity.x)


func got_hit(_damage: float):
	#state_machine._on_child_transition(state_machine.current_state,"EnemyHit")
	$"State Machine/EnemyAttack".go_to_hit()

func death():
	$"State Machine/EnemyAttack".go_to_absorb()
