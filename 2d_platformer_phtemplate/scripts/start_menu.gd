# start_menu.gd
extends Control

@export var game_scene_path: String = "res://levels/test_level_1.tscn"
@export var hover_sound: AudioStream
@export_range(-80, 24) var hover_volume: float = 0.0

@onready var play_again_button = $Panel/VBoxContainer/PlayAgainButton
@onready var settings_button = $Panel/VBoxContainer/SettingsButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton
@onready var audio_player = $AudioStreamPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Set audio player to SFX bus
	if audio_player:
		audio_player.bus = "SFX"
	
	play_again_button.pressed.connect(_on_play_again_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	if hover_sound:
		play_again_button.mouse_entered.connect(_on_button_hover)
		settings_button.mouse_entered.connect(_on_button_hover)
		quit_button.mouse_entered.connect(_on_button_hover)

func _on_play_again_pressed():
	if game_scene_path != "":
		get_tree().change_scene_to_file(game_scene_path)

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://menus/settings_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_button_hover():
	if hover_sound and audio_player:
		audio_player.stream = hover_sound
		audio_player.volume_db = hover_volume
		audio_player.play()
