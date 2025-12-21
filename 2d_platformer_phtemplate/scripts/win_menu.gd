# win_menu.gd
extends Control

@export var game_scene: String = "res://levels/test_level_1.tscn"
@export var main_menu_scene: String = "res://menus/start_menu.tscn"
@export var hover_sound: AudioStream
@export_range(-80, 24) var hover_volume: float = 0.0

@onready var score_label = $Panel/VBoxContainer/ScoreLabel
@onready var play_again_button = $Panel/VBoxContainer/PlayAgainButton
@onready var main_menu_button = $Panel/VBoxContainer/MainMenuButton
@onready var quit_button = $Panel/VBoxContainer/QuitButton
@onready var audio_player = $AudioStreamPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Set audio player to SFX bus
	if audio_player:
		audio_player.bus = "SFX"
	
	print("=== WinMenu _ready() started ===")
	print("Score label: ", score_label)
	print("Play again button: ", play_again_button)
	print("Main menu button: ", main_menu_button)
	print("Quit button: ", quit_button)
	
	score_label.text = "Score: %05d" % GameManager.score
	
	play_again_button.pressed.connect(_on_play_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	if hover_sound:
		play_again_button.mouse_entered.connect(_on_button_hover)
		main_menu_button.mouse_entered.connect(_on_button_hover)
		quit_button.mouse_entered.connect(_on_button_hover)
	
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

func _on_quit_pressed():
	print("!!! QUIT PRESSED !!!")
	get_tree().quit()

func _on_button_hover():
	if hover_sound and audio_player:
		audio_player.stream = hover_sound
		audio_player.volume_db = hover_volume
		audio_player.play()
