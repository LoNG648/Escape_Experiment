extends StaticBody2D

func on_hit(attack_type: String):
	if attack_type == "tankSpecial":
		queue_free()  # disappear
