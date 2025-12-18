extends Node2D

@export var point_value: int = 1
@export var collect_sound: AudioStream

@onready var sprite = $Sprite2D
@onready var area = $Area2D
@onready var audio_player = $AudioStreamPlayer2D

var collected: bool = false

func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is PlatformerController2D and not collected:
		collected = true
		area.set_deferred("monitoring", false)
		call_deferred("_collect")

func _collect():
	sprite.visible = false
	GameManager.add_score(point_value)
	
	if collect_sound and audio_player:
		audio_player.stream = collect_sound
		audio_player.play()
		await audio_player.finished
	
	queue_free()
