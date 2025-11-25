extends State
class_name EnemyFollow

@export var enemy : CharacterBody2D
@export var move_speed = 80
var player: CharacterBody2D

func Enter(): 
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	var direction = player.global_position.x - enemy.global_position.x
	
	if direction.normalized() > 25:
		enemy.velocity.x = direction.normalized() * move_speed
	else:
		enemy.velocity.x = 0
