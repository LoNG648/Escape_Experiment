extends State
class_name EnemyAttack

@export var enemy : CharacterBody2D
@export var attack_ms = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attacking = false
var animating = false
var held_speed = 0
var from_hit = false
var mid_attack = false


@onready var animation_player = $"../../Sprite"
@onready var hurtbox_collision = $"../../Hurtbox/Hurtbox Collision"
@onready var detection_box = $"../../Detectionbox/Detectionbox Collision"
#@onready var enemy = $"../.."

func Enter():
	attacking = true
	#$"../EnemyHit".in_hit = false
	#animating = true
	#animation_player.play("windup1")
	#await animation_player.animation_finished
	#animation_player.play("attack1")
	#hurtbox_collision.disabled = false
	#attacking = true
	#await animation_player.animation_finished
	#hurtbox_collision.disabled = true
	#animation_player.play("holster1")
	#await animation_player.animation_finished
	#animating = false

func Physics_Update(delta):
	var player = get_tree().get_first_node_in_group("Player")
	var current_animation = animation_player.get_animation()
	var direction = player.global_position - enemy.global_position
	
	#enemy.velocity = direction.normalized() * attack_ms
	enemy.velocity.x = attack_ms
	enemy.velocity.y = gravity * delta
	
	#if held_speed < 0:
		#hurtbox_collision.scale.x = abs(hurtbox_collision.scale) * -1
		#detection_box.scale.x = abs(detection_box.scale) * -1
		
	
	if attacking == true and animating == false and $"../EnemyFollow".in_range == true:
		animating = true
		animation_player.play("1windup")
		#if animation_player.get_animation() == "1windup":
		await animation_player.animation_finished
		animation_player.play("1attack")
		mid_attack = true
		hurtbox_collision.disabled = false
			#hurtbox_collision.set_deferred("disabled", false)
			#if animation_player.get_animation() == "1attack":
		await animation_player.animation_finished
		mid_attack = false
		#hurtbox_collision.disabled = true
				#hurtbox_collision.set_deferred("disabled", true)
		animation_player.play("1holster")
				#if animation_player.get_animation() == "1holster":
		await animation_player.animation_finished
		#await get_tree().create_timer(0.3).timeout
		animating = false
	
	if mid_attack == false and attacking == false:
		Transitioned.emit(self, "EnemyFollow")


func _on_front_detectionbox_body_exited(body: Node2D) -> void:
	if body is Player:
		$"../EnemyFollow".in_range = false
		#hurtbox_collision.disabled = true
		await animation_player.animation_finished
		hurtbox_collision.set_deferred("disabled", true)
		attacking = false

func exit():
	hurtbox_collision.set_deferred("disabled", true)
	animating = false
	attacking = false

func go_to_hit():
	Transitioned.emit(self, "EnemyHit")

func go_to_absorb():
	Transitioned.emit(self, "EnemyAbsorb")

func _on_sprite_animation_finished() -> void:
	if mid_attack == true:
		hurtbox_collision.disabled = true
