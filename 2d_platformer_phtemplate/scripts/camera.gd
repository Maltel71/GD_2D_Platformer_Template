# camera.gd
extends Camera2D

@export var smoothing_speed: float = 5.0
@export var shake_intensity: float = 10.0
@export var shake_duration: float = 0.3

var player: Node2D
var shake_timer: float = 0.0
var shake_offset: Vector2 = Vector2.ZERO

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("player_hurt"):
		player.player_hurt.connect(_on_player_hurt)

func _process(delta):
	# Handle shake
	if shake_timer > 0:
		shake_timer -= delta
		shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
	else:
		shake_offset = Vector2.ZERO
	
	# Follow player with shake offset
	if player:
		var target_pos = player.global_position + shake_offset
		global_position = global_position.lerp(target_pos, smoothing_speed * delta)

func _on_player_hurt():
	shake_timer = shake_duration
