extends Node2D

var speed = 500
var direction = 1  # 1 for right, -1 for left

@onready var area = $Area2D  # Reference to the Area2D child

func _ready():
	# Connect the collision signal
	if area:
		area.body_entered.connect(_on_body_entered)
	
	# Auto-destroy after 3 seconds
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _process(delta):
	position.x += speed * direction * delta

func set_direction(dir):
	direction = dir
	if dir < 0:
		scale.x = -1

func _on_body_entered(body):
	# Handle collision with enemies, walls, etc.
	if body.is_in_group("enemy"):
		# body.take_damage(10)  # Add damage logic here
		pass
	queue_free()  # Destroy bullet on impact
