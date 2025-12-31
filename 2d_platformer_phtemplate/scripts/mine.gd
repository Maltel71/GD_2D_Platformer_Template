extends Node2D

@export var explosion_delay: float = 2.0
@export var damage_amount: int = 2
@export var knockback_strength: float = 600.0
@export var blink_interval_start: float = 0.5
@export var blink_interval_end: float = 0.05
@export_range(0.5, 2.0) var pitch_start: float = 1.0
@export_range(0.5, 2.0) var pitch_end: float = 1.5
@export var explosion_sound: AudioStream
@export var fuse_sound: AudioStream

@onready var sprite = $AnimatedSprite2D
@onready var static_sprite = $MineSprite01V1
@onready var trigger_area = $TriggerArea2D
@onready var blast_area = $BlastArea2D
@onready var audio = $AudioStreamPlayer2D

var triggered: bool = false
var blinking: bool = false

func _ready():
	trigger_area.body_entered.connect(_on_trigger_entered)
	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")

func _on_trigger_entered(body):
	if body is PlatformerController2D and not triggered:
		triggered = true
		blinking = true
		_blink_and_beep()
		await get_tree().create_timer(explosion_delay).timeout
		_explode()

func _blink_and_beep():
	var elapsed_time: float = 0.0
	
	while blinking:
		# Calculate current blink interval and pitch based on progress
		var progress = elapsed_time / explosion_delay
		var current_interval = lerp(blink_interval_start, blink_interval_end, progress)
		var current_pitch = lerp(pitch_start, pitch_end, progress)
		
		static_sprite.self_modulate = Color(10, 10, 10, 1)
		if fuse_sound and audio:
			audio.stream = fuse_sound
			audio.pitch_scale = current_pitch
			audio.play()
		await get_tree().create_timer(current_interval).timeout
		elapsed_time += current_interval
		
		static_sprite.self_modulate = Color.WHITE
		await get_tree().create_timer(current_interval).timeout
		elapsed_time += current_interval

func _explode():
	blinking = false
	static_sprite.visible = false
	sprite.visible = false
	
	if sprite.sprite_frames.has_animation("explode"):
		sprite.visible = true
		sprite.play("explode")
	
	if explosion_sound and audio:
		audio.stream = explosion_sound
		audio.pitch_scale = 1.0
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
