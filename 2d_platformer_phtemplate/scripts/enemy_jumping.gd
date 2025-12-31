extends CharacterBody2D

@export_group("Movement Settings")
## The strength of the vertical jump.
@export var jump_force: float = 400.0
## The horizontal speed applied during a jump.
@export var horizontal_speed: float = 150.0
## Time in seconds between jumps.
@export var jump_interval: float = 2.0

@export_group("Combat")
## How many hits the enemy can take before disappearing.
@export var max_health: int = 3
## Damage dealt to the player upon contact with the AttackArea.
@export var damage_amount: int = 1

@export_group("Sound Effects")
@export var idle_sound: AudioStream
@export_range(-80, 24) var idle_volume: float = 0.0
@export var hurt_sound: AudioStream
@export_range(-80, 24) var hurt_volume: float = 0.0
@export var death_sound: AudioStream
@export_range(-80, 24) var death_volume: float = 0.0
@export var jump_sound: AudioStream
@export_range(-80, 24) var jump_volume: float = 0.0
@export var in_air_sound: AudioStream
@export_range(-80, 24) var in_air_volume: float = 0.0
@export var landing_sound: AudioStream
@export_range(-80, 24) var landing_volume: float = 0.0

@onready var sprite = $AnimatedSprite2D
@onready var wall_ray_right = $WallRayRight
@onready var wall_ray_left = $WallRayLeft
@onready var ledge_ray_right = $LedgeRayRight
@onready var ledge_ray_left = $LedgeRayLeft
@onready var attack_area = $AttackArea
@onready var blood_splatter = $BloodSplatter
@onready var idle_player = $IdlePlayer
@onready var sfx_player = $SFXPlayer
@onready var in_air_player = $InAirPlayer

# Use project gravity settings to keep physics consistent
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: int = 1 
var jump_timer: float = 0.0
var current_health: int
var was_in_air: bool = false

func _ready():
	current_health = max_health
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	
	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	
	# Hide blood splatter initially
	if blood_splatter:
		blood_splatter.visible = false
	
	# Set audio bus and start idle loop
	if idle_player:
		idle_player.bus = "SFX"
		if idle_sound:
			idle_player.stream = idle_sound
			idle_player.volume_db = idle_volume
			idle_player.play()
	
	if sfx_player:
		sfx_player.bus = "SFX"
	
	if in_air_player:
		in_air_player.bus = "SFX"

func _physics_process(delta):
	# Track air state for landing detection
	var is_in_air = not is_on_floor()
	
	# Apply gravity if in the air
	if is_in_air:
		velocity.y += gravity * delta
		
		# Start in-air sound if just left ground
		if not was_in_air and in_air_sound and in_air_player:
			in_air_player.stream = in_air_sound
			in_air_player.volume_db = in_air_volume
			in_air_player.play()
	else:
		# Apply friction when landing so the ball stops sliding
		velocity.x = move_toward(velocity.x, 0, horizontal_speed * delta * 10)
		
		# Play landing sound if just hit ground
		if was_in_air:
			_play_sound(landing_sound, landing_volume)
			if in_air_player:
				in_air_player.stop()
		
		# Handle jump timing
		jump_timer += delta
		if jump_timer >= jump_interval:
			_prepare_jump()
	
	was_in_air = is_in_air
	move_and_slide()
	_update_visuals()

func _prepare_jump():
	jump_timer = 0.0
	
	# Decide direction based on obstacles/ledges
	if direction == 1:
		if wall_ray_right.is_colliding() or not ledge_ray_right.is_colliding():
			direction = -1
	else:
		if wall_ray_left.is_colliding() or not ledge_ray_left.is_colliding():
			direction = 1
	
	velocity.y = -jump_force
	velocity.x = direction * horizontal_speed
	
	# Play jump sound
	_play_sound(jump_sound, jump_volume)

func _update_visuals():
	sprite.flip_h = (direction == -1)
	
	# Play jump animation in air
	if not is_on_floor():
		if sprite.animation != "jump":
			sprite.play("jump")
	# Play idle animation on ground
	else:
		if sprite.animation != "idle":
			sprite.play("idle")

## Call this function from your player's attack script to hurt the enemy
func take_damage(amount: int):
	current_health -= amount
	_play_sound(hurt_sound, hurt_volume)
	if current_health <= 0:
		_die()

func _die():
	# Stop idle and in-air sounds
	if idle_player:
		idle_player.stop()
	if in_air_player:
		in_air_player.stop()
	
	# Play death sound
	_play_sound(death_sound, death_volume)
	
	# Hide main sprite
	sprite.visible = false
	
	# Disable collision
	set_physics_process(false)
	attack_area.set_deferred("monitoring", false)
	
	# Play blood splatter
	if blood_splatter:
		blood_splatter.visible = true
		blood_splatter.play()
		await blood_splatter.animation_finished
	
	queue_free()

func _on_attack_area_body_entered(body):
	if body is PlatformerController2D:
		# Consistent with how the health pickup heals the player 
		if body.has_method("take_damage"):
			body.take_damage(damage_amount)
		elif "current_health" in body:
			body.current_health -= damage_amount

func _play_sound(sound: AudioStream, volume: float):
	if sound and sfx_player:
		sfx_player.stream = sound
		sfx_player.volume_db = volume
		sfx_player.play()
