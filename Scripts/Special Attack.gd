#Generic stuff
extends Node2D

#Export Variables
@export var damage: float

#On Ready Variables
@onready var special_attack_raycast: RayCast2D = $"Special Attack Raycast"
@onready var dev_line: Line2D = $"Dev Line"

#Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dev_line.points.clear()
	dev_line.add_point(special_attack_raycast.position)
	dev_line.add_point(special_attack_raycast.target_position)
	#Checks if Dev Mode is on and adds a line to help with testing the special attack
	if Globals.DeveloperMode == true:
		#dev_line.points.clear()
		pass
		#dev_line.show()
		#dev_line.add_point(special_attack_raycast.position)
		#dev_line.add_point(special_attack_raycast.target_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta) -> void:
	if special_attack_raycast.is_colliding():
		dev_line.default_color = Color.RED
		
		var hit_object = special_attack_raycast.get_collider()
			
	else:
		dev_line.default_color = Color.GREEN
