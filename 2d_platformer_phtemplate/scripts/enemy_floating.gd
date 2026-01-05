extends CharacterBody2D

@export var speed: float = 80.0
@export var health: int = 3
@export var patrol_time: float = 2.0  # Time before switching direction
@export var damage_to_player: int = 1
@export var sprite_faces_right: bool = true  # Set to false if your sprite art faces left

@export_category("Sound Effects")
@export var idle_sound: AudioStream
@export_range(-80, 24) var idle_volume: float = 0.0
@export var hurt_sound: AudioStream
@export_range(-80, 24) var hurt_volume: float = 0.0
@export var death_sound: AudioStream
@export_range(-80, 24) var death_volume: float = 0.0
@export var flying_sound: AudioStream
@export_range(-80, 24) var flying_volume: float = 0.0

var direction: int = 1  # 1 = right, -1 = left
var time_in_direction: float = 0.0
var can_damage: bool = true
var damage_cooldown: float = 1.0

@onready var attack_area = $AttackArea
@onready var anim_sprite = $AnimatedSprite2D
@onready var blood_splatter = $BloodSplatter
@onready var idle_player = $IdlePlayer
@onready var sfx_player = $SFXPlayer
@onready var flying_player = $FlyingPlayer

func _ready():
	attack_area.body_entered.connect(_on_attack_area_entered)
	
	# Hide blood splatter initially
	if blood_splatter:
		blood_splatter.visible = false
	
	# Set audio bus and start idle loop
	if idle_player:
		idle_player.bus = "sfx"
		if idle_sound:
			idle_player.stream = idle_sound
			idle_player.volume_db = idle_volume
			idle_player.play()
	
	if sfx_player:
		sfx_player.bus = "sfx"
	
	# Start flying sound loop
	if flying_player:
		flying_player.bus = "sfx"
		if flying_sound:
			flying_player.stream = flying_sound
			flying_player.volume_db = flying_volume
			flying_player.play()

func _physics_process(delta):
	# Update patrol timer
	time_in_direction += delta
	if time_in_direction >= patrol_time:
		_turn_around()
		time_in_direction = 0.0
	
	# Move
	velocity.x = speed * direction
	velocity.y = 0  # No gravity, stays in air
	# Flip sprite based on direction and which way it originally faces
	if sprite_faces_right:
		anim_sprite.flip_h = direction < 0
	else:
		anim_sprite.flip_h = direction > 0
	
	# Play animations
	if velocity.x != 0:
		anim_sprite.play("walk")
	else:
		anim_sprite.play("idle")
	
	move_and_slide()

func _turn_around():
	direction *= -1

func take_damage(amount: int):
	health -= amount
	_play_sound(hurt_sound, hurt_volume)
	if health <= 0:
		_die()

func _die():
	# Stop idle and flying sounds
	if idle_player:
		idle_player.stop()
	if flying_player:
		flying_player.stop()
	
	# Play death sound
	_play_sound(death_sound, death_volume)
	
	# Hide main sprite
	anim_sprite.visible = false
	
	# Disable collision
	set_physics_process(false)
	attack_area.set_deferred("monitoring", false)
	
	# Play blood splatter
	if blood_splatter:
		blood_splatter.visible = true
		blood_splatter.play()
		await blood_splatter.animation_finished
	
	queue_free()

func _on_attack_area_entered(body):
	if body is PlatformerController2D and can_damage:
		body.take_damage(damage_to_player)
		can_damage = false
		await get_tree().create_timer(damage_cooldown).timeout
		can_damage = true

func _play_sound(sound: AudioStream, volume: float):
	if sound and sfx_player:
		sfx_player.stream = sound
		sfx_player.volume_db = volume
		sfx_player.play()
