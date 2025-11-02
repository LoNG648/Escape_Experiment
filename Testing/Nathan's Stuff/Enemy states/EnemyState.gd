extends Node2D

class_name EnemyState

@export var can_move : bool = true

@onready var debug = owner.find_child("debug")
@onready var player = owner.get_parent().find_child("player")
@onready var sprite = owner.find_child("Sprite")

func _read():
	set_physics_process(false)

func enter():
	set_physics_process(true)

func exit():
	set_physics_process(false)

func transition():
	pass

func _physics_process(delta: float) -> void:
	transition()
	debug.text = name
