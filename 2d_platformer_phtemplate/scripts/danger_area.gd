extends Area2D

# Danger Area Script
# Use this for spikes, lava, hazards, etc.
# Add this to an Area2D node and configure the damage amount

@export_category("Danger Settings")
@export var damage_amount: int = 1
@export var continuous_damage: bool = false
@export_range(0.1, 5.0) var damage_interval: float = 1.0

var can_damage: bool = true
var bodies_inside: Array = []

func _ready():
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set up collision layers
	# Layer 3 is typically used for hazards/triggers
	collision_layer = 4  # Binary: 100 (layer 3)
	collision_mask = 1   # Binary: 001 (detects layer 1 - player)

func _on_body_entered(body):
	# Check if the body is the player
	if body.is_in_group("player") and body.has_method("take_damage"):
		if continuous_damage:
			# Add to tracking array for continuous damage
			if not bodies_inside.has(body):
				bodies_inside.append(body)
				_start_continuous_damage(body)
		else:
			# Deal damage once on contact
			if can_damage:
				body.take_damage(damage_amount)
				can_damage = false
				# Reset damage cooldown to prevent multiple hits
				await get_tree().create_timer(0.5).timeout
				can_damage = true

func _on_body_exited(body):
	# Remove from tracking when player leaves
	if continuous_damage and bodies_inside.has(body):
		bodies_inside.erase(body)

func _start_continuous_damage(body):
	# Continuously damage while in contact
	while bodies_inside.has(body) and is_instance_valid(body):
		if body.has_method("take_damage"):
			body.take_damage(damage_amount)
		await get_tree().create_timer(damage_interval).timeout
