extends Control


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/test_level.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
