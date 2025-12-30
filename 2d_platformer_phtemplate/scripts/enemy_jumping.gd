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

@onready var sprite = $AnimatedSprite2D
@onready var wall_ray_right = $WallRayRight
@onready var wall_ray_left = $WallRayLeft
@onready var ledge_ray_right = $LedgeRayRight
@onready var ledge_ray_left = $LedgeRayLeft
@onready var attack_area = $AttackArea
@onready var blood_splatter = $BloodSplatter

# Use project gravity settings to keep physics consistent
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: int = 1 
var jump_timer: float = 0.0
var current_health: int

func _ready():
	current_health = max_health
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	
	if sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
	
	# Hide blood splatter initially
	if blood_splatter:
		blood_splatter.visible = false

func _physics_process(delta):
	# Apply gravity if in the air
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Apply friction when landing so the ball stops sliding
		velocity.x = move_toward(velocity.x, 0, horizontal_speed * delta * 10)
		
		# Handle jump timing
		jump_timer += delta
		if jump_timer >= jump_interval:
			_prepare_jump()

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
	# Optional: add a hit animation or sound here
	if current_health <= 0:
		_die()

func _die():
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
