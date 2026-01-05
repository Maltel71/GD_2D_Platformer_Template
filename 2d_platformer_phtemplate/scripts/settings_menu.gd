# settings_menu.gd
extends Control

@export var hover_sound: AudioStream
@export_range(-80, 24) var hover_volume: float = 0.0

@onready var master_volume = $Panel/VBoxContainer/MasterVolume
@onready var sfx_volume = $Panel/VBoxContainer/SFXVolume
@onready var music_volume = $Panel/VBoxContainer/MusicVolume
@onready var god_mode_toggle = $Panel/VBoxContainer/god_mode_toggle
@onready var ok_button = $Panel/VBoxContainer/OKButton
@onready var audio_player = $AudioStreamPlayer

func _ready():
	# Set audio player to SFX bus
	if audio_player:
		audio_player.bus = "SFX"
	
	# Load saved volumes BEFORE connecting signals
	master_volume.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	music_volume.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	sfx_volume.value = db_to_linear(AudioServer.get_bus_volume_db(2))
	
	# Load saved god mode state
	god_mode_toggle.button_pressed = GlobalSettings.god_mode_enabled
	
	# Now connect signals
	master_volume.value_changed.connect(_on_master_volume_changed)
	sfx_volume.value_changed.connect(_on_sfx_volume_changed)
	music_volume.value_changed.connect(_on_music_volume_changed)
	god_mode_toggle.toggled.connect(_on_god_mode_toggled)
	ok_button.pressed.connect(_on_back_pressed)
	
	if hover_sound:
		ok_button.mouse_entered.connect(_on_button_hover)
	
	master_volume.min_value = 0
	master_volume.max_value = 1
	sfx_volume.min_value = 0
	sfx_volume.max_value = 1
	music_volume.min_value = 0
	music_volume.max_value = 1

func _on_back_pressed():
	get_tree().change_scene_to_file("res://menus/StartMenu.tscn")

func _on_master_volume_changed(value: float):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_sfx_volume_changed(value: float):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_music_volume_changed(value: float):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_god_mode_toggled(toggled: bool):
	GlobalSettings.god_mode_enabled = toggled

func _on_button_hover():
	if hover_sound and audio_player:
		audio_player.stream = hover_sound
		audio_player.volume_db = hover_volume
		audio_player.play()
