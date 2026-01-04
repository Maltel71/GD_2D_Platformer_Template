extends CharacterBody2D

@export var speed: float = 100.0
@export var health: int = 3
@export var wall_detection_distance: float = 30.0
@export var damage_to_player: int = 1
@export var drop_item: PackedScene  # Assign coin, health pickup, etc.
@export var sprite_faces_right: bool = true  # Set to false if your sprite art faces left

@export_category("Sound Effects")
@export var idle_sound: AudioStream
@export_range(-80, 24) var idle_volume: float = 0.0
@export var hurt_sound: AudioStream
@export_range(-80, 24) var hurt_volume: float = 0.0
@export var death_sound: AudioStream
@export_range(-80, 24) var death_volume: float = 0.0
@export var walk_sound_1: AudioStream
@export var walk_sound_2: AudioStream
@export var walk_sound_3: AudioStream
@export_range(-80, 24) var walk_volume: float = 0.0
@export_range(0.1, 2.0) var footstep_interval: float = 0.5

var direction: int = 1  # 1 = right, -1 = left
var footstep_timer: float = 0.0
var gravity: float = 980.0
var can_damage: bool = true
var damage_cooldown: float = 1.0

@onready var wall_ray_right = $WallRayRight
@onready var wall_ray_left = $WallRayLeft
@onready var ledge_ray_right = $LedgeRayRight
@onready var ledge_ray_left = $LedgeRayLeft
@onready var attack_area = $AttackArea
@onready var anim_sprite = $AnimatedSprite2D
@onready var blood_splatter = $BloodSplatter
@onready var idle_player = $IdlePlayer
@onready var sfx_player = $SFXPlayer

func _ready():
	# Set raycast distances
	wall_ray_right.target_position.x = wall_detection_distance
	wall_ray_left.target_position.x = -wall_detection_distance
	
	# Connect attack area
	attack_area.body_entered.connect(_on_attack_area_entered)
	
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

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	# Check for walls or ledges
	if (wall_ray_right.is_colliding() or not ledge_ray_right.is_colliding()) and direction == 1:
		_turn_around()
	elif (wall_ray_left.is_colliding() or not ledge_ray_left.is_colliding()) and direction == -1:
		_turn_around()
	
	# Continuous damage check
	if can_damage and attack_area.has_overlapping_bodies():
		for body in attack_area.get_overlapping_bodies():
			if body is PlatformerController2D:
				body.take_damage(damage_to_player)
				can_damage = false
				_reset_damage_cooldown()
				break
	
	# Move
	velocity.x = speed * direction
	# Flip sprite based on direction and which way it originally faces
	if sprite_faces_right:
		anim_sprite.flip_h = direction < 0
	else:
		anim_sprite.flip_h = direction > 0
	
	# Play animations
	if velocity.x != 0:
		anim_sprite.play("walk")
		# Footstep sounds
		footstep_timer += delta
		if footstep_timer >= footstep_interval:
			_play_footstep()
			footstep_timer = 0.0
	else:
		anim_sprite.play("idle")
		footstep_timer = 0.0
	
	move_and_slide()

func _turn_around():
	direction *= -1
	# Flip AttackArea's CollisionShape2D
	if attack_area:
		var collision_shape = attack_area.get_node("CollisionShape2D")
		if collision_shape:
			collision_shape.position.x = -collision_shape.position.x

func take_damage(amount: int):
	health -= amount
	_play_sound(hurt_sound, hurt_volume)
	if health <= 0:
		_die()

func _die():
	# Stop idle sound
	if idle_player:
		idle_player.stop()
	
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
	
	# Drop item
	_drop_item()
	
	queue_free()

func _drop_item():
	if drop_item:
		var item = drop_item.instantiate()
		item.global_position = global_position
		get_parent().add_child(item)

func _on_attack_area_entered(body):
	if body is PlatformerController2D and can_damage:
		body.take_damage(damage_to_player)
		can_damage = false
		_reset_damage_cooldown()

func _reset_damage_cooldown():
	await get_tree().create_timer(damage_cooldown).timeout
	can_damage = true

func _play_sound(sound: AudioStream, volume: float):
	if sound and sfx_player:
		sfx_player.stream = sound
		sfx_player.volume_db = volume
		sfx_player.play()

func _play_footstep():
	var sounds = []
	if walk_sound_1:
		sounds.append(walk_sound_1)
	if walk_sound_2:
		sounds.append(walk_sound_2)
	if walk_sound_3:
		sounds.append(walk_sound_3)
	
	if sounds.size() > 0:
		var random_sound = sounds[randi() % sounds.size()]
		_play_sound(random_sound, walk_volume)
