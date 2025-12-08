extends CharacterBody2D
class_name Tank_Boss

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_left = false
var facing_right = true
var blocking = false
var flip = false

@onready var detection_box = $"Detectionbox/Detectionbox Collision"
@onready var hurtbox_collision = $"Hurtbox/Hurtbox Collision"
@onready var collision = $CollisionBox
@onready var floor_raycast = $"Floor Raycast"
@onready var wall_raycast = $"Wall Raycast"
@onready var hitbox_collision = $"Hitbox/Hitbox Collision"
@onready var player_raycast: RayCast2D = $"Player Detect Raycast"
@onready var state_collision = $StateArea/StateCollision
@onready var special_detection = $"DetectionBoxSpecial/DetectionboxS Collision"
@onready var special_hurtbox = $"HurtboxSpecial/Hurtbox Special Collision"

@onready var state_machine = $"State Machine"

func _ready() -> void:
	pass

func _physics_process(delta):
	var distance = global_position.x
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	
	move_and_slide()
	
	

func update_facing(dir: float):
	var s: float = signf(dir)
	hurtbox_collision.position.x = abs(hurtbox_collision.position.x) * s
	detection_box.position.x = abs(detection_box.position.x) * s
	hitbox_collision.position.x = abs(hitbox_collision.position.x) * s
	wall_raycast.position.x = abs(wall_raycast.position.x) * s
	wall_raycast.scale = abs(wall_raycast.scale) * s
	floor_raycast.position.x = abs(floor_raycast.position.x) * s
	collision.position.x = abs(collision.position.x) * s
	player_raycast.position.x = abs(player_raycast.position.x) * s
	player_raycast.scale = abs(player_raycast.scale) * s
	state_collision.position.x = abs(state_collision.position.x) * s
	special_detection.position.x = abs(special_detection.position.x) * s
	special_hurtbox.position.x = abs(special_hurtbox.position.x) * s
	$Sprite.flip_h = (s < 0)



func got_hit(_damage: float):
	$"State Machine/EnemyAttack".go_to_hit()

func death():
	$"State Machine/EnemyAttack".go_to_absorb()
