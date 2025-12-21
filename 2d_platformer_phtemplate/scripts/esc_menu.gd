extends CanvasLayer

@onready var master_volume = $Panel/VBoxContainer/MasterVolume
@onready var music_volume = $Panel/VBoxContainer/MusicVolume
@onready var sfx_volume = $Panel/VBoxContainer/SFXVolume

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	$Panel/VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$Panel/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	# Set slider ranges (0 to 1)
	master_volume.min_value = 0
	master_volume.max_value = 1
	music_volume.min_value = 0
	music_volume.max_value = 1
	sfx_volume.min_value = 0
	sfx_volume.max_value = 1
	
	# Load current volumes from AudioServer BEFORE connecting signals
	master_volume.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	music_volume.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	sfx_volume.value = db_to_linear(AudioServer.get_bus_volume_db(2))
	
	# Connect sliders AFTER loading values
	master_volume.value_changed.connect(_on_master_volume_changed)
	music_volume.value_changed.connect(_on_music_volume_changed)
	sfx_volume.value_changed.connect(_on_sfx_volume_changed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_resume_pressed()
			return
		else:
			# Reload volumes when opening menu
			master_volume.value = db_to_linear(AudioServer.get_bus_volume_db(0))
			music_volume.value = db_to_linear(AudioServer.get_bus_volume_db(1))
			sfx_volume.value = db_to_linear(AudioServer.get_bus_volume_db(2))
			
			show()
			get_tree().paused = true

func _on_resume_pressed():
	hide()
	get_tree().paused = false

func _on_quit_pressed():
	get_tree().quit()

func _on_master_volume_changed(value: float):
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

func _on_music_volume_changed(value: float):
	AudioServer.set_bus_volume_db(1, linear_to_db(value))

func _on_sfx_volume_changed(value: float):
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
