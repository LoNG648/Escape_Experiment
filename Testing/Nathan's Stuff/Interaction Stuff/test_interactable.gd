extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var label = $Label
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var collision_shape_2d: CollisionShape2D = $InteractionArea/CollisionShape2D

#const sign_text = "Space to Jump"

func _ready():
	label.hide()
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	collision_shape_2d.disabled = true
	label.show()

#give it the interaction area, another area for when they leave and a label



func _on_area_2d_body_exited(body: Node2D) -> void:
	collision_shape_2d.set_deferred("disabled", false)
	label.hide()


func _on_interaction_area_body_entered(body: Node2D) -> void:
	pass
