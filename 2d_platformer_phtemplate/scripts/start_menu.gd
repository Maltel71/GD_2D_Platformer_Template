extends Control

@export var game_scene_path: String = "res://path/to/your/game.tscn"
@export var hover_sound: AudioStream

@onready var start_button = $VBoxContainer/StartButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var audio_player = $AudioStreamPlayer

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	start_button.mouse_entered.connect(_on_button_hover)
	quit_button.mouse_entered.connect(_on_button_hover)

func _on_start_pressed():
	if game_scene_path != "":
		get_tree().change_scene_to_file(game_scene_path)
	else:
		print("Game scene path not set!")

func _on_quit_pressed():
	get_tree().quit()

func _on_button_hover():
	if hover_sound and audio_player:
		audio_player.stream = hover_sound
		audio_player.play()
