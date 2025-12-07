extends State
class_name EnemyHit

@export var enemy : CharacterBody2D

@onready var animation_player = $"../../Sprite"
@onready var hitbox_collision = $"../../Hitbox/Hitbox Collision"
@onready var hurtbox_collision = $"../../Hurtbox/Hurtbox Collision"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var hit_ms = 0

func Enter():
	# Immediate disable for this frame
	#hitbox_collision.disabled = true
	#hurtbox_collision.disabled = true
	hitbox_collision.set_deferred("disabled", true)
	hurtbox_collision.set_deferred("disabled", true)
	
	# Set global immunity timer (runs during hit anim + extra time after)
	var state_machine = get_parent()
	state_machine.set_hit_immunity(randf_range(state_machine.hit_immunity_duration_min, state_machine.hit_immunity_duration_max))
	
	animation_player.play("hit")
	animation_player.animation_finished.connect(_on_animation_finished)
	flash_white()

func flash_white():
	# Reset to normal color first
	enemy.modulate = Color.WHITE
	
	# Create a quick double-flash tween for punchy hit feedback
	var tween = create_tween()
	tween.set_parallel(false)  # Chain sequentially for flash-flash-back
	
	# Flash 1: Bright white
	tween.tween_property(enemy, "modulate", Color(1.8, 1.8, 1.8, 1.0), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Back to normal briefly
	tween.tween_property(enemy, "modulate", Color.WHITE, 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Flash 2: Slightly brighter for extra pop
	tween.tween_property(enemy, "modulate", Color(2.0, 2.0, 2.0, 1.0), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Final reset to normal
	tween.tween_property(enemy, "modulate", Color.WHITE, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func Physics_Update(delta):
	enemy.velocity.x = hit_ms
	enemy.velocity.y += gravity * delta

func exit():
	animation_player.animation_finished.disconnect(_on_animation_finished)
	enemy.modulate = Color.WHITE  # Safety reset

func _on_animation_finished():
	if animation_player.animation == "hit":
		Transitioned.emit(self, "EnemyFollow")
