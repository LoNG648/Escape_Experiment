extends State
class_name EnemyFollow

@export var enemy : CharacterBody2D
@export var move_speed = 110
var in_range = false
var go_to_idle = false
#var player: CharacterBody2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var hurtbox_collision = $"../../Hurtbox/Hurtbox Collision"
@onready var floor_raycast: RayCast2D = $"../../Floor Raycast"
@onready var wall_raycast: RayCast2D = $"../../Wall Raycast"
@onready var player_raycast: RayCast2D = $"../../Player Detect Raycast"

#@onready var player = get_tree().get_first_node_in_group("player")

func Enter(): 
	#player = get_tree().get_first_node_in_group("Player")
	pass

#func _physics_process(delta: float) -> void:
func Physics_Update(delta):
	var player = get_tree().get_first_node_in_group("Player")
	var direction_to_player = (player.global_position - enemy.global_position).normalized()
	
	if go_to_idle == true:
		Transitioned.emit(self, "EnemyIdle")
		go_to_idle = false
	
	enemy.velocity.x = direction_to_player.x * move_speed
	if !enemy.is_on_floor():
		enemy.velocity.y += gravity * delta
	
	if in_range == true:
		Transitioned.emit(self, "EnemyAttack")
	
	if !floor_raycast.is_colliding() && enemy.is_on_floor() && !player_raycast.is_colliding() and in_range == false:
		move_speed = 0
		$"../../Sprite".play("idle")
	elif wall_raycast.is_colliding() && enemy.is_on_floor() && !player_raycast.is_colliding() and in_range == false:
		move_speed = 0
		$"../../Sprite".play("idle")
	elif player_raycast.is_colliding():
		enemy.update_facing(direction_to_player.x)
	else:
		enemy.update_facing(direction_to_player.x)
		move_speed = 110
		$"../../Sprite".play("run")
	

func _on_body_exited(body):
	if body is Player:
		go_to_idle = true
		#Transitioned.emit(self, "EnemyIdle")

func exit():
	go_to_idle = false

func _on_front_detectionbox_body_entered(body: Node2D) -> void:
	if body is Player:
		in_range = true
		$"../EnemyAttack".held_speed = enemy.velocity.x

func _on_front_detectionbox_body_exited(body: Node2D) -> void:
	if body is Player:
		in_range = false
