if specialAttack == "tankSpecial":
	animation_timer.start(2)
	velocity.x = move_toward(velocity.x, 0, SPEED*2)
	collector_sprite.visible = false
	tank_sprite.visible = true
	tank_sprite.play("Special Attack")
	
	await get_tree().create_timer(1).timeout
	
	shockwave_sprite.visible = true
	shockwave_sprite.play("Shockwave")
	
	# Enable the Area2D hurtbox
	tank_special_attack_hurtbox_collision.disabled = false
	
	# ✅ Check for overlapping bodies and hit the wall
	for body in tank_special_attack_hurtbox_collision.get_overlapping_bodies():
		if body.has_method("on_hit"):
			body.on_hit("tankSpecial")
	
	await animation_timer.timeout
	
	# Disable hurtbox & reset visuals
	tank_special_attack_hurtbox_collision.disabled = true
	shockwave_sprite.visible = false
	tank_sprite.visible = false
	collector_sprite.visible = true
