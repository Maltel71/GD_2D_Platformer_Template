extends Node2D

@export var jump_boost: float = 800.0
@export var boost_sound: AudioStream

@onready var area = $Area2D
@onready var anim_sprite = $AnimatedSprite2D
@onready var audio_player = $AudioStreamPlayer2D

func _ready():
	area.body_entered.connect(_on_body_entered)
	if anim_sprite:
		anim_sprite.play("idle")

func _on_body_entered(body):
	if body is PlatformerController2D:
		var boost_direction = -global_transform.y.normalized()
		body.velocity = boost_direction * jump_boost
		
		if anim_sprite:
			anim_sprite.play("activated")
			await anim_sprite.animation_finished
			anim_sprite.play("idle")
		
		if boost_sound and audio_player:
			audio_player.stream = boost_sound
			audio_player.play()
