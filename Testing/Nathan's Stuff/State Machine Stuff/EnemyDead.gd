extends State
class_name EnemyDead

@export var enemy: CharacterBody2D

@onready var animation_player = $"../../Sprite"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func Enter():
	animation_player.play("death")
	await animation_player.animation_finished
	enemy.queue_free()

func Update(delta: float):
	enemy.velocity.x = 0
	enemy.velocity.y = gravity * delta

func exit():
	pass
