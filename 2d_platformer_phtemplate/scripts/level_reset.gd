# level_reset.gd
extends Node

func _input(event):
	if event.is_action_pressed("reset_level"):
		if get_tree().get_first_node_in_group("player"):
			get_tree().reload_current_scene()
