extends State
class_name EnemyAttack

@export var enemy : CharacterBody2D
@export var attack_ms = 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attacking = false
var animating = false
var held_speed = 0
var from_hit = false
var mid_attack = false
var recovery_timer : float = 0.0

@onready var animation_player = $"../../Sprite"
@onready var hurtbox_collision = $"../../Hurtbox/Hurtbox Collision"
@onready var detection_box = $"../../Detectionbox/Detectionbox Collision"

func Enter():
	attacking = true
	if from_hit:
		recovery_timer = 0.3
		from_hit = false
	animation_player.animation_finished.connect(_on_animation_finished)

func Physics_Update(delta):
	var player = get_tree().get_first_node_in_group("Player")
	var direction = player.global_position - enemy.global_position
	
	enemy.velocity.x = attack_ms
	enemy.velocity.y += gravity * delta  # Use += for proper gravity
	
	if recovery_timer > 0:
		recovery_timer -= delta
		# Optional: Play a recovery animation if you have one, or idle
		animation_player.play("idle")
		return
	
	if attacking and not animating and $"../EnemyFollow".in_range:
		animating = true
		animation_player.play("1windup")
	
	if mid_attack == false and attacking == false:
		Transitioned.emit(self, "EnemyFollow")

func _on_front_detectionbox_body_exited(body: Node2D) -> void:
	if body is Player:
		$"../EnemyFollow".in_range = false
		# Wait for current animation to finish if needed, but avoid await here
		# Instead, set a flag
		attacking = false
		hurtbox_collision.disabled = true  # Immediate disable, but use set_deferred if issues

func exit():
	animation_player.animation_finished.disconnect(_on_animation_finished)
	#hurtbox_collision.disabled = true
	hurtbox_collision.set_deferred("disabled", true)
	animating = false
	attacking = false
	mid_attack = false

func go_to_hit():
	Transitioned.emit(self, "EnemyHit")

func go_to_absorb():
	Transitioned.emit(self, "EnemyAbsorb")

func go_to_dead():
	Transitioned.emit(self, "EnemyDead")

func _on_animation_finished() -> void:
	var finished_anim = animation_player.animation
	if finished_anim == "1windup":
		animation_player.play("1attack")
		mid_attack = true
		hurtbox_collision.disabled = false
	elif finished_anim == "1attack":
		mid_attack = false
		hurtbox_collision.disabled = true
		animation_player.play("1holster")
	elif finished_anim == "1holster":
		animating = false
		recovery_timer = 0.1
		# Optional: Add a short cooldown here if you don't want immediate re-attack
		# recovery_timer = 0.3  # For example
