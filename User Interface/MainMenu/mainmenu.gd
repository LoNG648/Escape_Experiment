extends Control

var DeveloperMode: bool
var DeveloperName: String

@onready var testing: Button = $VBoxContainer/Buttons/Testing
@onready var dev_node: Node = $"Globals/Dev Node"

func _ready() -> void:
	if dev_node.DeveloperMode == false:
		return
	elif dev_node.DeveloperMode == true:
		testing.visible = true
		Globals.set("DeveloperMode", true)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/Level One.tscn")

func _on_help_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/helpscreen.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_test_room_pressed() -> void:
	if dev_node.DeveloperName == "Gray":
		get_tree().change_scene_to_file("res://Testing/Gray's Stuff/Gray Test Level.tscn")
		Globals.set("DeveloperName", "Gray")
	elif dev_node.DeveloperName == "Jack":
		get_tree().change_scene_to_file("res://Testing/Jack's Stuff/Jack Test Level.tscn")
		Globals.set("DeveloperName", "Jack")
	elif dev_node.DeveloperName == "Max":
		get_tree().change_scene_to_file("res://Testing/Max's Stuff/Max Test Level.tscn")
		Globals.set("DeveloperName", "Max")
	elif dev_node.DeveloperName == "Nathan":
		get_tree().change_scene_to_file("res://Testing/Nathan's Stuff/Levels/Nathan Test Level.tscn")
		Globals.set("DeveloperName", "Nathan")
	elif dev_node.DeveloperName == "Ryan":
		get_tree().change_scene_to_file("res://Testing/Ryan's Stuff/Ryan Test Level.tscn")
		Globals.set("DeveloperName", "Ryan")
