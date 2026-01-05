# gizmo_enabler.gd
extends Node

func _ready():
	# Enable gizmos in running game
	get_tree().debug_collisions_hint = false
	
	# Optional: Also enable other debug visualizations
	# get_tree().debug_navigation_hint = true
