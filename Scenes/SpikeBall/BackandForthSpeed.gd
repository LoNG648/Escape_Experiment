extends PathFollow2D

var direction = 1

func _process(_delta):
	progress_ratio += .02 * direction
	if progress_ratio == 1:
		direction = -1
	if progress_ratio == 0:
		direction = 1
