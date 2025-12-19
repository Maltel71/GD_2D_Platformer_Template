# win_menu.gd
extends Control



@export var game_scene: String = "res://levels/test_level_1.tscn"
@export var main_menu_scene: String = "res://menus/start_menu.tscn"

@onready var score_label = $Panel/VBoxContainer/ScoreLabel
@onready var play_again_button = $Panel/VBoxContainer/PlayAgainButton
@onready var main_menu_button = $Panel/VBoxContainer/MainMenuButton
@onready var settings_button = $Panel/VBoxContainer/SettingsButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # ADD THIS LINE FIRST
	
	print("=== WinMenu _ready() started ===")
	print("Score label: ", score_label)
	print("=== WinMenu _ready() started ===")
	print("Score label: ", score_label)
	print("Play again button: ", play_again_button)
	print("Main menu button: ", main_menu_button)
	print("Settings button: ", settings_button)
	print("Quit button: ", quit_button)
	
	score_label.text = "Score: %05d" % GameManager.score
	
	# THESE NEED TO BE INDENTED INSIDE _ready()
	play_again_button.pressed.connect(_on_play_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	print("=== All connections done ===")
	get_tree().paused = true

func _on_play_again_pressed():
	print("!!! PLAY AGAIN PRESSED !!!")
	get_tree().paused = false
	get_tree().change_scene_to_file(game_scene)

func _on_main_menu_pressed():
	print("!!! MAIN MENU PRESSED !!!")
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene)

func _on_settings_pressed():
	print("!!! SETTINGS PRESSED !!!")
	SettingsMenu.show_menu()

func _on_quit_pressed():
	print("!!! QUIT PRESSED !!!")
	get_tree().quit()
