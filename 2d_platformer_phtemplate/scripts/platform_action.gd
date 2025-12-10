extends Resource

class_name PlatformAction

@export_enum("move_x", "move_y", "rotate", "wait") var type: String = "move_x"
@export var distance: float = 0.0  # For move_x/move_y
@export var degrees: float = 0.0   # For rotate
@export var duration: float = 1.0
