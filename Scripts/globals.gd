extends Node

var DeveloperMode: bool = false
var DeveloperName: String = ""
var KeyCollected: bool = false

var player_position: Vector2 = Vector2.ZERO

func update_player_position(new_position: Vector2):
	player_position = new_position
	

var coin_count: int = 0
