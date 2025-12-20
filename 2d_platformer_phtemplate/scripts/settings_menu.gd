# settings_menu.gd
extends Control

@onready var master_volume = $Panel/VBoxContainer/MasterVolume
@onready var sfx_volume = $Panel/VBoxContainer/SFXVolume
@onready var music_volume = $Panel/VBoxContainer/MusicVolume
@onready var god_mode_toggle = $Panel/VBoxContainer/GodModeToggle
@onready var ok_button = $Panel/VBoxContainer/OKButton

var god_mode_enabled: bool = false

func _ready():
	# Load saved volumes BEFORE connecting signals
	master_volume.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	sfx_volume.value = db_to_linear(AudioServer.get_bus_volume_db(2))
	music_volume.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	
	# Now connect signals
	master_volume.value_changed.connect(_on_master_volume_changed)
	sfx_volume.value_changed.connect(_on_sfx_volume_changed)
	music_volume.value_changed.connect(_on_music_volume_changed)
	
	god_mode_toggle.toggled.connect(_on_god_mode_toggled)
	ok_button.pressed.connect(_on_back_pressed)
	
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
	god_mode_enabled = toggled
