extends CharacterBody2D

@export var speed: float = 100.0
@export var health: int = 3
@export var wall_detection_distance: float = 30.0
@export var damage_to_player: int = 1
@export var drop_item: PackedScene
@export var sprite_faces_right: bool = true
@export var bullet_scene: PackedScene
@export var shoot_cooldown: float = 1.0

var direction: int = 1
var gravity: float = 980.0
var can_damage: bool = true
var can_shoot: bool = true
var damage_cooldown: float = 1.0
var player_detected: bool = false

@onready var wall_ray_right = $WallRayRight
@onready var wall_ray_left = $WallRayLeft
@onready var ledge_ray_right = $LedgeRayRight
@onready var ledge_ray_left = $LedgeRayLeft
@onready var attack_area = $AttackArea
@onready var anim_sprite = $AnimatedSprite2D
@onready var detection_ray_right = $DetectionRayRight
@onready var detection_ray_left = $DetectionRayLeft
@onready var bullet_spawn = $BulletSpawnPoint
@onready var blood_splatter = $BloodSplatter

func _ready():
	wall_ray_right.target_position.x = wall_detection_distance
	wall_ray_left.target_position.x = -wall_detection_distance
	detection_ray_right.enabled = true
	detection_ray_left.enabled = true
	attack_area.body_entered.connect(_on_attack_area_entered)
	
	# Hide blood splatter initially
	if blood_splatter:
		blood_splatter.visible = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	# Check for player detection using the correct raycast
	player_detected = false
	var active_ray = detection_ray_right if direction == 1 else detection_ray_left
	
	if active_ray.is_colliding():
		var collider = active_ray.get_collider()
		if collider is PlatformerController2D:
			player_detected = true
			velocity.x = 0
			if can_shoot and bullet_scene:
				_shoot()
	
	# Only patrol if player not detected
	if not player_detected:
		if (wall_ray_right.is_colliding() or not ledge_ray_right.is_colliding()) and direction == 1:
			_turn_around()
		elif (wall_ray_left.is_colliding() or not ledge_ray_left.is_colliding()) and direction == -1:
			_turn_around()
		
		velocity.x = speed * direction
	
	# Flip sprite
	if sprite_faces_right:
		anim_sprite.flip_h = direction < 0
	else:
		anim_sprite.flip_h = direction > 0
	
	# Flip bullet spawn point
	bullet_spawn.position.x = abs(bullet_spawn.position.x) * direction
	
	# Animations
	if player_detected:
		anim_sprite.play("idle")
	elif velocity.x != 0:
		anim_sprite.play("walk")
	else:
		anim_sprite.play("idle")
	
	# Melee damage
	if can_damage and attack_area.has_overlapping_bodies():
		for body in attack_area.get_overlapping_bodies():
			if body is PlatformerController2D:
				body.take_damage(damage_to_player)
				can_damage = false
				_reset_damage_cooldown()
				break
	
	move_and_slide()

func _turn_around():
	direction *= -1

func _shoot():
	can_shoot = false
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn.global_position
	bullet.set_direction(direction)
	get_parent().add_child(bullet)
	
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		_die()

func _die():
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
