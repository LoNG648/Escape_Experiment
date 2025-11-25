extends State
class_name EnemyFollow

@export var enemy : CharacterBody2D
@export var move_speed = 110
var in_range = false
#var player: CharacterBody2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#@onready var player = get_tree().get_first_node_in_group("player")

func Enter(): 
	#player = get_tree().get_first_node_in_group("Player")
	pass

#func _physics_process(delta: float) -> void:
func Physics_Update(delta):
	var player = get_tree().get_first_node_in_group("Player")
	var direction = player.global_position - enemy.global_position
	
	enemy.velocity = direction.normalized() * move_speed
	enemy.velocity.y = gravity * delta
	
	#if direction.length() < 20:
		#enemy.velocity = direction.normalized() * move_speed
		#enemy.velocity.y = gravity * delta
	#else:
		#enemy.velocity.x = 0
		#enemy.velocity.y = gravity * delta
	
	
	#if direction.length() > 20:
		#Transitioned.emit(self, "EnemyIdle")

func _on_body_exited(body):
	if body is Player:
		Transitioned.emit(self, "EnemyIdle")

func exit():
	pass
