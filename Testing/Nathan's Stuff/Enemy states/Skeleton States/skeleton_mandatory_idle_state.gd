extends EnemyState

var can_transition = false
@onready var right_raycast = $"../../Right Raycast"
@onready var left_raycast = $"../../Left Raycast"

func enter():
	super.enter()
	can_transition = false
	sprite.play("idle")
	can_transition = true

func transition():
	if can_transition:
		if owner.player_in_range and right_raycast.is_colliding() and owner.direction == Vector2.LEFT:
			get_parent().change_state("Chase State")
		elif owner.player_in_range and left_raycast.is_colliding() and owner.direction == Vector2.RIGHT:
			get_parent().change_state("Chase State")
		elif not owner.player_in_range:
			get_parent().change_state("Idle State")
