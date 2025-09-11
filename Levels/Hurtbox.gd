class_name Hurtbox
extends Area2D

var playerOverlap = false

func onBodyEntered(body: Node2D) -> void:
	if body is player:
		playerOverlap = true

func onBodyExited(body: Node2D) -> void:
	if body is player:
		playerOverlap = false
