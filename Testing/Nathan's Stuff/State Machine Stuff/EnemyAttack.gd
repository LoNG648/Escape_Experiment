extends State
class_name EnemyAttack

@export var enemy : CharacterBody2D
@export var attack_ms = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attacking = false
var animating = false

@onready var animation_player = $"../../Sprite"
@onready var hurtbox_collision = $"../../Hurtbox/Hurtbox Collision"
#@onready var enemy = $"../.."

func Enter(): 
	animating = true
	animation_player.play("windup1")
	await animation_player.animation_finished
	animation_player.play("attack1")
	hurtbox_collision.disabled = false
	attacking = true
	await animation_player.animation_finished
	hurtbox_collision.disabled = true
	animating = false

func Physics_Update(delta):
	var player = get_tree().get_first_node_in_group("Player")
	
	enemy.velocity.x = 0
	enemy.velocity.y = gravity * delta
	
	if attacking == true:
		animating = true
		animation_player.play("windup1")
		await animation_player.animation_finished
		animation_player.play("attack1")
		hurtbox_collision.disabled = false
		await animation_player.animation_finished
		hurtbox_collision.disabled = true
		animating = false
	
	#if animating == false and attacking == false:
		#Transitioned.emit(self, "EnemyFollow")


func _on_front_detectionbox_body_exited(body: Node2D) -> void:
	if body is Player:
		attacking = false
		Transitioned.emit(self, "EnemyFollow")

func exit():
	pass
