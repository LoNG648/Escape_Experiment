extends EnemyState

var can_transition = false

func enter():
	super.enter()
	can_transition = false
	sprite.play("hit")
	await sprite.animation_finished
	can_transition = true

func transition():
	if can_transition:
		get_parent().change_state("Idle State")
