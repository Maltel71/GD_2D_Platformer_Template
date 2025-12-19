# settings_menu.gd (AutoLoad as "SettingsMenu")
extends Control

@onready var master_volume = $Panel/VBoxContainer/MasterVolume
@onready var sfx_volume = $Panel/VBoxContainer/SFXVolume
@onready var music_volume = $Panel/VBoxContainer/MusicVolume
@onready var god_mode_toggle = $Panel/VBoxContainer/GodModeToggle
@onready var ok_button = $Panel/VBoxContainer/OKButton

var god_mode_enabled: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false  # Changed from panel.visible
	
	master_volume.value_changed.connect(_on_master_volume_changed)
	sfx_volume.value_changed.connect(_on_sfx_volume_changed)
	music_volume.value_changed.connect(_on_music_volume_changed)
	
	god_mode_toggle.toggled.connect(_on_god_mode_toggled)
	ok_button.pressed.connect(hide_menu)
	
	master_volume.min_value = 0
	master_volume.max_value = 1
	sfx_volume.min_value = 0
	sfx_volume.max_value = 1
	music_volume.min_value = 0
	music_volume.max_value = 1
	
	master_volume.value = 0.8
	sfx_volume.value = 0.8
	music_volume.value = 0.8
	
func show_menu():
	visible = true  # Changed from panel.visible

func hide_menu():
	visible = false  # Changed from panel.visible

func _on_master_volume_changed(value: float):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_sfx_volume_changed(value: float):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))

func _on_music_volume_changed(value: float):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_god_mode_toggled(toggled: bool):
	god_mode_enabled = toggled
