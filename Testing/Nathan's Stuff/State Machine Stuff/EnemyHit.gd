extends State
class_name EnemyHit

@export var enemy : CharacterBody2D

@onready var animation_player = $"../../Sprite"
@onready var hitbox_collision = $"../../Hitbox/Hitbox Collision"
@onready var enemy_attack = $"../EnemyAttack"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var hit_ms = 0
var in_hit = false

func Enter():
	#hitbox_collision.disabled = true
	#in_hit = true
	hitbox_collision.set_deferred("disabled", true)
	animation_player.play("hit")
	#Transitioned.emit(self, "EnemyFollow")

func Physics_Update(delta):
	#hitbox_collision.disabled = true
	enemy.velocity.x = hit_ms
	enemy.velocity.y = gravity * delta

func _animation_finished():
	var current_animation = animation_player.get_animation()
	if current_animation == "hit":
		Transitioned.emit(self, "EnemyFollow")

func exit():
	enemy_attack.from_hit = true
	#in_hit = false
	#hitbox_collision.disabled = false
	hitbox_collision.set_deferred("disabled", false)
