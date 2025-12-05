extends Node2D

@export var point_value: int = 1
@export var collect_sound: AudioStream

@onready var sprite = $Sprite2D  # or AnimatedSprite2D
@onready var area = $Area2D
@onready var audio_player = $AudioStreamPlayer2D

func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is PlatformerController2D:
		_collect()

func _collect():
	# Hide visuals immediately
	sprite.visible = false
	
	# Disable collision
	area.monitoring = false
	
	# Update score
	GameManager.add_score(point_value)
	
	# Play sound
	if collect_sound and audio_player:
		audio_player.stream = collect_sound
		audio_player.play()
	
	# Delete after sound finishes
	await get_tree().create_timer(1.0).timeout
	queue_free()
