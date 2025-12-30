extends Node2D

@export var explosion_delay: float = 2.0
@export var damage_amount: int = 2
@export var knockback_strength: float = 600.0
@export var explosion_sound: AudioStream

@onready var sprite = $AnimatedSprite2D
@onready var static_sprite = $MineSprite01V1
@onready var trigger_area = $TriggerArea2D
@onready var blast_area = $BlastArea2D
@onready var audio = $AudioStreamPlayer2D

var triggered: bool = false

func _ready():
	trigger_area.body_entered.connect(_on_trigger_entered)
	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")

func _on_trigger_entered(body):
	if body is PlatformerController2D and not triggered:
		triggered = true
		await get_tree().create_timer(explosion_delay).timeout
		_explode()

func _explode():
	static_sprite.visible = false
	sprite.visible = false
	
	if sprite.sprite_frames.has_animation("explode"):
		sprite.visible = true
		sprite.play("explode")
	
	if explosion_sound and audio:
		audio.stream = explosion_sound
		audio.play()
	
	# Damage and knockback
	for body in blast_area.get_overlapping_bodies():
		if body is PlatformerController2D:
			body.take_damage(damage_amount)
			
			# Calculate direction from mine to player
			var direction = (body.global_position - global_position).normalized()
			
			# Apply knockback force
			body.velocity = direction * knockback_strength
	
	if sprite.sprite_frames.has_animation("explode"):
		await sprite.animation_finished
	elif audio.playing:
		await audio.finished
	
	queue_free()
