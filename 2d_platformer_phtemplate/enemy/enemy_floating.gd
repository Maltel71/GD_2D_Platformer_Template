extends CharacterBody2D

@export var speed: float = 80.0
@export var health: int = 3
@export var patrol_time: float = 2.0  # Time before switching direction
@export var damage_to_player: int = 1

var direction: int = 1  # 1 = right, -1 = left
var time_in_direction: float = 0.0
var can_damage: bool = true
var damage_cooldown: float = 1.0

@onready var attack_area = $AttackArea
@onready var sprite = $Sprite2D  # or AnimatedSprite2D

func _ready():
	attack_area.body_entered.connect(_on_attack_area_entered)

func _physics_process(delta):
	# Update patrol timer
	time_in_direction += delta
	if time_in_direction >= patrol_time:
		_turn_around()
		time_in_direction = 0.0
	
	# Move
	velocity.x = speed * direction
	velocity.y = 0  # No gravity, stays in air
	sprite.scale.x = abs(sprite.scale.x) * direction
	
	move_and_slide()

func _turn_around():
	direction *= -1

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		queue_free()

func _on_attack_area_entered(body):
	if body is PlatformerController2D and can_damage:
		body.take_damage(damage_to_player)
		can_damage = false
		await get_tree().create_timer(damage_cooldown).timeout
		can_damage = true
