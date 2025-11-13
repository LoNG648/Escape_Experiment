extends Area2D

@export var amount: int = 1

func _ready() -> void:
	monitoring = true
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		Globals.KeyCollected == true
		hide()
	
