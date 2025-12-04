extends State
class_name EnemyAbsorb

@export var enemy: CharacterBody2D

@onready var animation_player = $"../../Sprite"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func Enter():
	$"../../Label2".show()
	animation_player.play("absorb")
	await animation_player.animation_finished
	animation_player.play("absorb_static")
	await get_tree().create_timer(5).timeout
	Transitioned.emit(self, "EnemyDead")

func exit():
	$"../../Label2".hide()
