extends State
class_name EnemyIdle

@export var enemy: CharacterBody2D
@export var move_speed := 70
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var player: CharacterBody2D

@onready var floor_raycast: RayCast2D = $"../../Floor Raycast"
@onready var wall_raycast: RayCast2D = $"../../Wall Raycast"

var move_direction : float
var wander_time : float

func randomize_wander():
	#move_direction = randf_range(-1,1)
	move_direction = 1 if randi() % 2 == 0 else -1
	wander_time= randf_range(2,4)

func Enter():
	#player = get_tree().get_first_node_in_group("Player")
	var player = Player
	randomize_wander()

func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	
	else:
		randomize_wander()

func Physics_Update(delta: float):
	if enemy:
		enemy.velocity.x = move_direction * move_speed
		if not enemy.is_on_floor():
			enemy.velocity.y += gravity * delta
		$"../../Sprite".play("run")
	
	if (!floor_raycast.is_colliding() || wall_raycast.is_colliding()) && enemy.is_on_floor():
		move_direction = -move_direction
		wander_time = randf_range(2, 3)
	
		
	#var direction = player.global_position - enemy.global_position
	#if direction.length() < 20:
		#Transitioned.emit(self, "EnemyFollow")

func _on_body_entered(body):
	if body is Player:
		Transitioned.emit(self, "EnemyFollow")

func exit():
	pass
