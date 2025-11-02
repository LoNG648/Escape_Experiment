extends Control
class_name helpscreen


func _on_back_to_mm_pressed() -> void:
	get_tree().change_scene_to_file("res://User Interface/MainMenu/mainmenu.tscn")
