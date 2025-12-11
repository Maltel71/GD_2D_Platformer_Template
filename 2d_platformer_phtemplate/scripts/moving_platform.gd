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
var timer: float = 0.0
var phase: int = 0  # 0=move_out, 1=rotate_out, 2=move_back, 3=rotate_back

func _ready():
	start_position = global_position
	start_rotation = rotation
	if start_delay > 0:
		await get_tree().create_timer(start_delay).timeout

func _physics_process(delta):
	if not loop and phase >= (4 if ping_pong else 2):
		return
	
	timer += delta
	var t: float
	
	match phase:
		0:  # Move out
			if move_duration > 0 and (move_distance_x != 0 or move_distance_y != 0):
				t = clamp(timer / move_duration, 0.0, 1.0)
				global_position = start_position.lerp(start_position + Vector2(move_distance_x, move_distance_y), t)
				if t >= 1.0:
					_advance()
			else:
				_advance()
		1:  # Rotate out
			if rotate_duration > 0 and rotate_degrees != 0:
				t = clamp(timer / rotate_duration, 0.0, 1.0)
				rotation = lerp_angle(start_rotation, start_rotation + deg_to_rad(rotate_degrees), t)
				if t >= 1.0:
					_advance()
			else:
				_advance()
		2:  # Move back
			if ping_pong and move_duration > 0:
				t = clamp(timer / move_duration, 0.0, 1.0)
				global_position = (start_position + Vector2(move_distance_x, move_distance_y)).lerp(start_position, t)
				if t >= 1.0:
					_advance()
			else:
				_reset()
		3:  # Rotate back
			if ping_pong and rotate_duration > 0:
				t = clamp(timer / rotate_duration, 0.0, 1.0)
				rotation = lerp_angle(start_rotation + deg_to_rad(rotate_degrees), start_rotation, t)
				if t >= 1.0:
					_reset()
			else:
				_reset()

func _advance():
	timer = 0.0
	phase += 1

func _reset():
	global_position = start_position
	rotation = start_rotation
	timer = 0.0
	phase = 0
