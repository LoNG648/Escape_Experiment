extends Node2D

@export var damage: float

@onready var line_2d: Line2D = $Line2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line_2d.points.clear()
	line_2d.show()
	line_2d.add_point(ray_cast_2d.position)
	line_2d.add_point(ray_cast_2d.target_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta) -> void:
	if ray_cast_2d.is_colliding():
		line_2d.default_color = Color.RED
	else:
		line_2d.default_color = Color.GREEN
