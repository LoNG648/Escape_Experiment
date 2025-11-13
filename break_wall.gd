class_name BreakableWall
extends StaticBody2D

var blocking = false

func death():
	queue_free()
	
func got_hit():
	pass
