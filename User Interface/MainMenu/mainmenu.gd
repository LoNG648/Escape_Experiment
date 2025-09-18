extends Control


func _on_start_pressed() -> void:
	#get_tree().change_scene_to_file("res://Scenes/Levels/test_level.tscn")
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_test_room_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/enemy_test_level.tscn")




func _on_nathans_test_level_pressed() -> void:
	get_tree().change_scene_to_file("res://Nathan's Stuff/levels/nathan_test_level.tscn")
