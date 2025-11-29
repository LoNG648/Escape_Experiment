extends State
class_name EnemyAttack

@export var enemy : CharacterBody2D
@export var attack_ms = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attacking = false



func Enter(): 
	$"../../Sprite".play("windup1")
	#await
	$"../../Sprite".play("attack1")
	$"../../Hurtbox/Hurtbox Collision".disabled = false
	attacking = true
	#await
	$"../../Hurtbox/Hurtbox Collision".disabled = true

func Physics_Update(delta):
	var player = get_tree().get_first_node_in_group("Player")
	
	enemy.velocity = attack_ms
	enemy.velocity.y = gravity * delta
	
	if attacking == true:
		$"../../Sprite".play("windup1")
		#await
		$"../../Sprite".play("attack1")
		$"../../Hurtbox/Hurtbox Collision".disabled = false
		#await
		$"../../Hurtbox/Hurtbox Collision".disabled = true
		


func _on_front_detectionbox_body_exited(body: Node2D) -> void:
	if body is Player:
		attacking = false
		Transitioned.emit(self, "EnemyFollow")
