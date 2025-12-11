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
var time_elapsed: float = 0.0
var current_phase: int = 0  # 0=move_forward, 1=rotate_forward, 2=move_back, 3=rotate_back

func _ready():
	start_position = global_position
	start_rotation = rotation
	
	if start_delay > 0:
		await get_tree().create_timer(start_delay).timeout

func _physics_process(delta):
	if not loop and current_phase >= (4 if ping_pong else 2):
		return
	
	time_elapsed += delta
	
	match current_phase:
		0:  # Move forward
			if move_distance_x != 0.0 or move_distance_y != 0.0:
				_update_movement(move_distance_x, move_distance_y, move_duration)
			else:
				_next_phase()
		1:  # Rotate forward
			if rotate_degrees != 0.0:
				_update_rotation(rotate_degrees, rotate_duration)
			else:
				_next_phase()
		2:  # Move back (ping pong)
			if ping_pong:
				_update_movement(-move_distance_x, -move_distance_y, move_duration)
			else:
				_reset_to_start()
		3:  # Rotate back (ping pong)
			if ping_pong:
				_update_rotation(-rotate_degrees, rotate_duration)
			else:
				current_phase = 0
				time_elapsed = 0.0

func _update_movement(x: float, y: float, duration: float):
	var t = clamp(time_elapsed / duration, 0.0, 1.0)
	
	if current_phase == 0:
		global_position = start_position.lerp(start_position + Vector2(x, y), t)
	else:  # phase 2 - moving back
		var end_pos = start_position + Vector2(move_distance_x, move_distance_y)
		global_position = end_pos.lerp(start_position, t)
	
	if t >= 1.0:
		_next_phase()

func _update_rotation(degrees: float, duration: float):
	var t = clamp(time_elapsed / duration, 0.0, 1.0)
	
	if current_phase == 1:
		rotation = lerp_angle(start_rotation, start_rotation + deg_to_rad(degrees), t)
	else:  # phase 3 - rotating back
		var end_rot = start_rotation + deg_to_rad(rotate_degrees)
		rotation = lerp_angle(end_rot, start_rotation, t)
	
	if t >= 1.0:
		_next_phase()

func _next_phase():
	time_elapsed = 0.0
	current_phase += 1
	
	if ping_pong and current_phase >= 4:
		current_phase = 0
	elif not ping_pong and current_phase >= 2:
		_reset_to_start()

func _reset_to_start():
	global_position = start_position
	rotation = start_rotation
	current_phase = 0
	time_elapsed = 0.0
