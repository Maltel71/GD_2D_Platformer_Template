extends CanvasLayer

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	$ColorRect/VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$ColorRect/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_on_resume_pressed()
		else:
			show()
			get_tree().paused = true

func _on_resume_pressed():
	hide()
	get_tree().paused = false

func _on_quit_pressed():
	get_tree().quit()
