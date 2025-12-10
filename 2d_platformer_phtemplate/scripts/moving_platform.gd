extends AnimatableBody2D

class_name MovingPlatform

@export var sequence: Array = []
@export var loop: bool = true
@export var start_delay: float = 0.0

var current_index: int = 0
var is_moving: bool = false
var start_position: Vector2
var start_rotation: float

func _ready():
	start_position = global_position
	start_rotation = rotation
	
	if start_delay > 0:
		await get_tree().create_timer(start_delay).timeout
	
	if sequence.size() > 0:
		_execute_sequence()

func _execute_sequence():
	is_moving = true
	
	while is_moving:
		if current_index >= sequence.size():
			if loop:
				current_index = 0
				global_position = start_position
				rotation = start_rotation
			else:
				is_moving = false
				break
		
		var action = sequence[current_index]
		await _perform_action(action)
		current_index += 1

func _perform_action(action: PlatformAction):
	if action.type == "move_x":
		await _move_axis("x", action.distance, action.duration)
	elif action.type == "move_y":
		await _move_axis("y", action.distance, action.duration)
	elif action.type == "rotate":
		await _rotate_platform(action.degrees, action.duration)
	elif action.type == "wait":
		await get_tree().create_timer(action.duration).timeout

func _move_axis(axis: String, distance: float, duration: float):
	var start_pos = global_position
	var target_pos = start_pos
	
	if axis == "x":
		target_pos.x += distance
	elif axis == "y":
		target_pos.y += distance
	
	var elapsed = 0.0
	while elapsed < duration:
		elapsed += get_process_delta_time()
		var t = clamp(elapsed / duration, 0.0, 1.0)
		global_position = start_pos.lerp(target_pos, t)
		await get_tree().process_frame
	
	global_position = target_pos

func _rotate_platform(degrees: float, duration: float):
	var start_rot = rotation
	var target_rot = start_rot + deg_to_rad(degrees)
	
	var elapsed = 0.0
	while elapsed < duration:
		elapsed += get_process_delta_time()
		var t = clamp(elapsed / duration, 0.0, 1.0)
		rotation = lerp_angle(start_rot, target_rot, t)
		await get_tree().process_frame
	
	rotation = target_rot
