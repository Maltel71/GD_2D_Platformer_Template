extends CharacterBody2D

@export var speed: float = 100.0
@export var health: int = 3
@export var wall_detection_distance: float = 30.0
@export var damage_to_player: int = 1
@export var drop_item: PackedScene  # Assign coin, health pickup, etc.

var direction: int = 1  # 1 = right, -1 = left
var gravity: float = 980.0
var can_damage: bool = true
var damage_cooldown: float = 1.0

@onready var wall_ray_right = $WallRayRight
@onready var wall_ray_left = $WallRayLeft
@onready var ledge_ray_right = $LedgeRayRight
@onready var ledge_ray_left = $LedgeRayLeft
@onready var attack_area = $AttackArea
@onready var sprite = $Sprite2D  # or AnimatedSprite2D

func _ready():
	# Set raycast distances
	wall_ray_right.target_position.x = wall_detection_distance
	wall_ray_left.target_position.x = -wall_detection_distance
	
	# Connect attack area
	attack_area.body_entered.connect(_on_attack_area_entered)

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
	sprite.scale.x = abs(sprite.scale.x) * direction
	
	move_and_slide()

func _turn_around():
	direction *= -1

func take_damage(amount: int):
	health -= amount
	if health <= 0:
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
