extends EnemyState

@export var patrol_timer = 5
var can_transition = false
var can_transition_chase = false

func enter():
	super.enter()
	can_transition = false
	can_transition_chase = false
	sprite.play("run")
	wait_for_patrol()
	can_transition_chase = true

func wait_for_patrol():
	await get_tree().create_timer(patrol_timer).timeout
	can_transition = true

func transition():
	if can_transition_chase and owner.player_in_range:
		get_parent().change_state("Chase State")
	elif can_transition:
		get_parent().change_state("Idle State")
