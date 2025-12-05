extends Camera2D

@export var smoothing_speed: float = 5.0

var player: Node2D

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	if player:
		global_position = global_position.lerp(player.global_position, smoothing_speed * delta)
