extends Area2D

@export var value: int = 1

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# Directly change a variable on the player
		# Replace "coins" with the player variable name you want to modify
		if body.has_variable("keyCollected"):
			body.keyCollected = true
		# Or set a specific variable
		# body.some_variable = new_value

		queue_free()
