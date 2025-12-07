extends State
class_name EnemyAbsorb

@export var enemy: CharacterBody2D
@export var static_time : float

@onready var animation_player = $"../../Sprite"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func Enter():
	$"../../Label2".show()
	animation_player.play("absorb")
	await animation_player.animation_finished
	animation_player.play("absorb_static")
	await get_tree().create_timer(static_time).timeout
	Transitioned.emit(self, "EnemyDead")

func exit():
	pass
