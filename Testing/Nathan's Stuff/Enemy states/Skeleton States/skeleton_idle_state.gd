extends EnemyState

@export var idle_timer = 1.5
var can_transition = false
var can_transition_chase = false

func enter():
	super.enter()
	can_transition = true
	sprite.play("Idle")
	await wait_for_idle()
	can_transition_chase = true
