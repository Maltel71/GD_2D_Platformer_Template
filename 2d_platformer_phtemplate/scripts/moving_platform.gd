extends AnimatableBody2D

@export_group("Movement")
@export var move_distance_x: float = 0.0
@export var move_distance_y: float = 0.0
@export var move_duration: float = 2.0

@export_group("Rotation")
@export var rotate_degrees: float = 0.0
@export var rotate_duration: float = 1.0

@export_group("Settings")
@export var loop: bool = true
@export var ping_pong: bool = false
@export var start_delay: float = 0.0

var start_position: Vector2
var start_rotation: float

func _ready():
	start_position = global_position
	start_rotation = rotation
	
	if start_delay > 0:
		await get_tree().create_timer(start_delay).timeout
	
	_execute_movement()

func _execute_movement():
	while true:
		# Move forward
		if move_distance_x != 0.0 or move_distance_y != 0.0:
			await _move(move_distance_x, move_distance_y, move_duration)
		
		# Rotate forward
		if rotate_degrees != 0.0:
			await _rotate(rotate_degrees, rotate_duration)
		
		if not loop:
			break
		
		if ping_pong:
			# Move back
			if move_distance_x != 0.0 or move_distance_y != 0.0:
				await _move(-move_distance_x, -move_distance_y, move_duration)
			
			# Rotate back
			if rotate_degrees != 0.0:
				await _rotate(-rotate_degrees, rotate_duration)
		else:
			# Teleport to start
			global_position = start_position
			rotation = start_rotation

func _move(x: float, y: float, duration: float):
	var start_pos = global_position
	var target_pos = start_pos + Vector2(x, y)
	
	var elapsed = 0.0
	while elapsed < duration:
		var delta = get_physics_process_delta_time()
		elapsed += delta
		var t = clamp(elapsed / duration, 0.0, 1.0)
		global_position = start_pos.lerp(target_pos, t)
		await get_tree().physics_frame
	
	global_position = target_pos

func _rotate(degrees: float, duration: float):
	var start_rot = rotation
	var target_rot = start_rot + deg_to_rad(degrees)
	
	var elapsed = 0.0
	while elapsed < duration:
		var delta = get_physics_process_delta_time()
		elapsed += delta
		var t = clamp(elapsed / duration, 0.0, 1.0)
		rotation = lerp_angle(start_rot, target_rot, t)
		await get_tree().physics_frame
	
	rotation = target_rot
