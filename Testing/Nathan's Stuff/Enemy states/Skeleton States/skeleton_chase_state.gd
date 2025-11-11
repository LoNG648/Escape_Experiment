extends EnemyState


@onready var right_raycast = $"../../Right Raycast"
@onready var left_raycast = $"../../Left Raycast"

var can_transition = false

func enter():
	super.enter()
	can_transition = false
	owner.mandatory_idle_active = false
	owner.reset_attack_state()
	sprite.play("run")
	can_transition = true

func transition():
	if can_transition:
		if owner.close_to_player:
			get_parent().change_state("Attack State")
		#elif owner.mandatory_idle_active and (left_raycast.is_colliding() or right_raycast.is_colliding()):
			#get_parent().change_state("Mandatory Idle State")
		elif not owner.player_in_range:
			get_parent().change_state("Idle State")
