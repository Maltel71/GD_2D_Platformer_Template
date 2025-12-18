# start_menu.gd
extends Control

@export var game_scene_path: String = "res://path/to/your/game.tscn"
@export var hover_sound: AudioStream

@onready var play_again_button = $VBoxContainer/PlayAgainButton
@onready var settings_button = $VBoxContainer/SettingsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var audio_player = $AudioStreamPlayer

func _ready():
	play_again_button.pressed.connect(_on_play_again_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	play_again_button.mouse_entered.connect(_on_button_hover)
	settings_button.mouse_entered.connect(_on_button_hover)
	quit_button.mouse_entered.connect(_on_button_hover)

func _on_play_again_pressed():
	if game_scene_path != "":
		get_tree().change_scene_to_file(game_scene_path)
	else:
		print("Game scene path not set!")

func _on_settings_pressed():
	SettingsMenu.show_menu()

func _on_quit_pressed():
	get_tree().quit()

func _on_button_hover():
	if hover_sound and audio_player:
		audio_player.stream = hover_sound
		audio_player.play()
