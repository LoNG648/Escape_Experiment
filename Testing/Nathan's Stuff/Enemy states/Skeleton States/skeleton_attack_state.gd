extends EnemyState

var can_transition = false

func enter():
	super.enter()
	can_transition = false
	sprite.play("windup1")
	await sprite.animation_finished
	sprite.play("attack1")
	await sprite.animation_finished
	owner.reset_attack_state()

func transition():
	if can_transition:
		if owner.player_in_range:
			get_parent().change_state("Chase State")
		else:
			get_parent().change_state("Idle State")
