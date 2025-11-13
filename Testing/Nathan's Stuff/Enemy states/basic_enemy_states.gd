extends CharacterBody2D

@onready var player_detection_area = $PlayerDetection
@onready var sprite = $Sprite
@onready var state_machine = $StateMachine
@onready var right_raycast = $"Right Raycast"
@onready var left_raycast = $"Left Raycast"
@onready var floor_raycast = $"Floor Raycast"
@onready var hurtbox_area = $Hitbox

var mandatory_idle_active = false
var player_in_range = false
var close_to_player = false
var direction = Vector2.RIGHT
var dead = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_right = true

@export var change_direction : float = 2.0
@export var stop_distance : float = 10
@export var attack_range : float = 35
@export var damage_dealt : int = 10
@export var move_speed = 20
@export var chase_speed = 60
@export var health = 50
@export var knockback_force = Vector2(250, -25)

func _ready():
	pass


func _physics_process(delta: float) -> void:
	var distance_to_player = global_position.distance_to(Globals.player_position)
	var player_position = Globals.player_position
	var direction_to_player_x = player_position.x - global_position.x
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	if player_in_range:
		if abs(direction_to_player_x) > change_direction:
			direction.x = sign(direction_to_player_x)
			$Sprite.flip_h = direction.x < 0
	
	if player_in_range == false:
		check_wall_collision()
	
	if distance_to_player <= attack_range and mandatory_idle_active == false:
		start_attack_animation()
	
	if player_in_range and right_raycast.is_colliding() and direction == Vector2.RIGHT:
		mandatory_transition()
	if player_in_range and left_raycast.is_colliding() and direction == Vector2.LEFT:
		mandatory_transition()
	
	if player_in_range and state_machine.check_if_can_move():
		if abs(direction_to_player_x) > stop_distance:
			velocity.x = direction.x * chase_speed
		else:
			velocity.x = 0
	else:
		if state_machine.check_if_can_move():
			velocity.x = direction.x * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
	
	update_attack_area_detection()
	move_and_slide()

func mandatory_transition():
	mandatory_idle_active = true
	#mandatory_idle_active = false

func update_attack_area_detection():
	if direction == Vector2.RIGHT:
		hurtbox_area.scale.x = 1
	else:
		hurtbox_area.scale.x = -1

func check_wall_collision():
	if right_raycast.is_colliding():
		direction = Vector2.LEFT
		$Sprite.flip_h = true
	if left_raycast.is_colliding():
		direction = Vector2.RIGHT
		$Sprite.flip_h = false

func start_attack_animation():
	close_to_player = true

func _on_player_detected(body):
	if body.is_in_group("Player"):
		player_in_range = true

func _on_player_lost(body):
	if body.is_in_group("Player"):
		player_in_range = false

#func _on_attack_entered(body):
	#if body.is_in_group("Player"):
		#body.take_damage(damage_dealt)

func reset_attack_state():
	close_to_player = false

func take_damage(damage):
	if dead:
		return
	#health -= damage
	#print(health)
	
	var player_position = Globals.player_position
	var knockback_direction = (global_position - player_position).normalized()
	apply_knockback(Vector2(knockback_force.x * knockback_direction.x, knockback_force.x))
	
	if health <= 0:
		die()
	else:
		state_machine.change_state("Hurt State")

func apply_knockback(force: Vector2):
	velocity = force
	move_and_slide()

func die():
	dead = true
	state_machine.change_state("Dead State")
