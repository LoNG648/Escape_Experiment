extends PathFollow2D

var direction = 1

func _process(_delta):
	progress_ratio += .003 * direction
	if progress_ratio == 1:
		direction = -3
	if progress_ratio == 0:
		direction = 3
