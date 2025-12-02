extends State
class_name EnemyAttack

@export var enemy : CharacterBody2D
@export var attack_ms = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attacking = false
var animating = false
var held_speed = 0

@onready var animation_player = $"../../Sprite"
@onready var hurtbox_collision = $"../../Hurtbox/Hurtbox Collision"
@onready var detection_box = $"../../FrontDetectionbox/Front Detectionbox Collision"
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
	var direction = player.global_position - enemy.global_position
	
	#enemy.velocity = direction.normalized() * attack_ms
	enemy.velocity.x = attack_ms
	enemy.velocity.y = gravity * delta
	
	#if held_speed < 0:
		#hurtbox_collision.scale.x = abs(hurtbox_collision.scale) * -1
		#detection_box.scale.x = abs(detection_box.scale) * -1
		
	
	if attacking == true and animating == false:
		animating = true
		animation_player.play("windup1")
		await animation_player.animation_finished
		animation_player.play("attack1")
		hurtbox_collision.disabled = false
		await animation_player.animation_finished
		hurtbox_collision.disabled = true
		await get_tree().create_timer(0.3).timeout
		animating = false
	
	
	#if direction.normalized > 0:
		
	
	#if animating == false and attacking == false:
		#Transitioned.emit(self, "EnemyFollow")


func _on_front_detectionbox_body_exited(body: Node2D) -> void:
	if body is Player:
		$"../EnemyFollow".in_range = false
		await animation_player.animation_finished
		attacking = false
		await get_tree().create_timer(0.35).timeout
		Transitioned.emit(self, "EnemyFollow")

func exit():
	#if held_speed < 0:
		#hurtbox_collision.scale.x = abs(hurtbox_collision.scale) * -1
		#detection_box.scale.x = abs(detection_box.scale) * -1
	hurtbox_collision.disabled = true
	animating = false
	attacking = false
	pass
