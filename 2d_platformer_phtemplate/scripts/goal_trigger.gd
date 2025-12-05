extends Node2D

@export var next_scene: PackedScene

@onready var area = $Area2D

func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is PlatformerController2D:
		_trigger_goal()

func _trigger_goal():
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
	else:
		push_warning("GoalTrigger: No next_scene assigned")
