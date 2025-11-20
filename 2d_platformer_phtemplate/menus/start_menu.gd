extends Control

@export var game_scene: PackedScene

@onready var start_button = $StartButton
@onready var quit_button = $QuitButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		print("Game scene not assigned!")

func _on_quit_pressed():
	get_tree().quit()
