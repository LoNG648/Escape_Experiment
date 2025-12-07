extends Node
class_name StateMachine  # Optional: add class_name for clarity

@export var initial_state : State
@export var hit_immunity_duration_min : float = 1.1
@export var hit_immunity_duration_max : float = 1.3

var current_state : State
var states : Dictionary = {}
var hit_immunity_timer : float = 0.0

@onready var label = $"../Label"
@onready var hitbox_collision : CollisionShape2D = $"../Hitbox/Hitbox Collision"  # Enemy's hurtbox (receives damage)

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(_on_child_transition)
	if initial_state:
		initial_state.Enter()
		current_state = initial_state
	hitbox_collision.disabled = false  # Ensure enabled initially

func _process(delta):
	if current_state:
		current_state.Update(delta)
	label.set_text(str(current_state.name))  # .name for cleaner label

func _physics_process(delta):
	# Manage hitbox immunity globally
	if hit_immunity_timer > 0:
		hit_immunity_timer -= delta
		hitbox_collision.disabled = true
	else:
		hitbox_collision.disabled = false
	
	if current_state:
		current_state.Physics_Update(delta)

func set_hit_immunity(duration: float):
	hit_immunity_timer = duration

func _on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
	if current_state:
		current_state.exit()
	
	new_state.Enter()
	current_state = new_state
