# win_menu.gd
extends Control

@export var main_menu_scene: String = "res://path/to/main_menu.tscn"

@onready var score_label = $Panel/VBoxContainer/ScoreLabel
@onready var play_again_button = $Panel/VBoxContainer/PlayAgainButton
@onready var main_menu_button = $Panel/VBoxContainer/MainMenuButton
@onready var settings_button = $Panel/VBoxContainer/SettingsButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton

func _ready():
	# Update score
	score_label.text = "Score: %05d" % GameManager.score
	
	# Connect buttons
	play_again_button.pressed.connect(_on_play_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Pause game
	get_tree().paused = true

func _on_play_again_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene)

func _on_settings_pressed():
	SettingsMenu.show_menu()

func _on_quit_pressed():
	get_tree().quit()
