extends Control

var paused: bool = false

func resume():
	paused = false
	get_tree().paused = false

func pause():
	paused = true
	get_tree().paused = true
	

func test_escape():
	if Input.is_action_just_pressed("Pause") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("Pause") and get_tree().paused == true:
		resume()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_resume_pressed() -> void:
	resume()


func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()

func _process(_delta):
	if paused == true:
		$".".show()
	elif paused == false:
		$".".hide()
	test_escape()


func _on_controls_pressed() -> void:
	#get_tree().change_scene_to_file("res://Testing/Nathan's Stuff/helpscreen.tscn")
	pass
