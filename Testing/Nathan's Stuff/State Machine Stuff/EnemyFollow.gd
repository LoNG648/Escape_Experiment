extends State
class_name EnemyFollow

@export var enemy : CharacterBody2D
@export var move_speed = 100
var player: CharacterBody2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func Enter(): 
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	var direction = player.global_position - enemy.global_position
	
	if direction.length() < 20:
		enemy.velocity = direction.normalized() * move_speed
		enemy.velocity.y = gravity * delta
	else:
		enemy.velocity.x = 0
		enemy.velocity.y = gravity * delta
	
	
	if direction.length() > 40:
		Transitioned.emit(self, "EnemyIdle")

func exit():
	pass
