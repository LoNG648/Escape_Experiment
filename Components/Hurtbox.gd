class_name Hurtbox
extends Area2D

var overlap = false
@export var damage: float

signal overlapOccurred(damage)

func onBodyEntered(body: Node2D) -> void:
	if body is player:
		overlap = true
		emit_signal("overlapOccurred",damage)

func onBodyExited(body: Node2D) -> void:
	if body is player:
		overlap = false
