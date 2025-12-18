extends Node2D

@export var next_scene: PackedScene

@onready var area = $Area2D

func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is PlatformerController2D:
		_trigger_goal()

func _trigger_goal():
	var win_menu = preload("res://menus/WinMenu.tscn").instantiate()
	get_tree().root.add_child(win_menu)
