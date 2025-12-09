extends Node

@onready var esc_menu = get_node("/root/YourMainScene/EscMenu")  # Adjust path

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if esc_menu:
			esc_menu.show_menu()
