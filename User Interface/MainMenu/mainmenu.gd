extends Control

@onready var dev_node: DevNode = $"Dev Node"
@onready var testing: Button = $VBoxContainer/Buttons/Testing

func _ready() -> void:
	if dev_node.DeveloperMode == false:
		return
	elif dev_node.DeveloperMode == true:
		testing.visible = true

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level One.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_test_room_pressed() -> void:
	if dev_node.DeveloperName == "Gray":
		get_tree().change_scene_to_file("res://Testing/Gray's Stuff/Gray Test Level.tscn")
	elif dev_node.DeveloperName == "Jack":
		get_tree().change_scene_to_file("res://Testing/Jack's Stuff/Jack Test Level.tscn")
	elif dev_node.DeveloperName == "Max":
		get_tree().change_scene_to_file("res://Testing/Max's Stuff/Max Test Level.tscn")
	elif dev_node.DeveloperName == "Nathan":
		get_tree().change_scene_to_file("res://Testing/Nathan's Stuff/Levels/Nathan Test Level.tscn")
	elif dev_node.DeveloperName == "Ryan":
		get_tree().change_scene_to_file("res://Testing/Ryan's Stuff/Ryan Test Level.tscn")
