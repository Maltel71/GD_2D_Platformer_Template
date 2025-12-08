extends Node2D

@export var health_amount: int = 1
@export var pickup_sound: AudioStream
@export var sprite: Sprite2D

@onready var area = $Area2D
@onready var audio_player = $AudioStreamPlayer2D

func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is PlatformerController2D:
		# Only pick up if player isn't at max health
		if body.current_health < body.max_health:
			# Hide immediately
			if sprite:
				sprite.visible = false
			_collect(body)

func _collect(player):
	# Disable collision (use set_deferred to avoid signal blocking)
	area.set_deferred("monitoring", false)
	
	# Heal player
	player.current_health = min(player.current_health + health_amount, player.max_health)
	
	# Play sound
	if pickup_sound and audio_player:
		audio_player.stream = pickup_sound
		audio_player.play()
		# Wait for sound to finish
		await audio_player.finished
	
	queue_free()
