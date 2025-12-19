extends Node2D

@export var next_scene: String = ""

@onready var area = $Area2D

var triggered = false

func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is PlatformerController2D and not triggered:
		triggered = true
		call_deferred("_trigger_goal")

func _trigger_goal():
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)
	else:
		push_warning("GoalTrigger: No next_scene path assigned")
