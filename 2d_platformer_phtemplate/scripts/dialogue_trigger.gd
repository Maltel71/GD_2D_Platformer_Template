# dialogue_trigger.gd
extends Node2D

@export_category("Section 1")
@export var section_1_label_1: Label
@export var section_1_label_1_duration: float = 3.0
@export var section_1_label_1_delay: float = 3.0

@export var section_1_label_2: Label
@export var section_1_label_2_duration: float = 3.0
@export var section_1_label_2_delay: float = 3.0

@export var section_1_label_3: Label
@export var section_1_label_3_duration: float = 3.0
@export var section_1_label_3_delay: float = 3.0

@export_category("Section 2")
@export var section_2_label_1: Label
@export var section_2_label_1_duration: float = 3.0
@export var section_2_label_1_delay: float = 3.0

@export var section_2_label_2: Label
@export var section_2_label_2_duration: float = 3.0
@export var section_2_label_2_delay: float = 3.0

@export var section_2_label_3: Label
@export var section_2_label_3_duration: float = 3.0
@export var section_2_label_3_delay: float = 3.0

@export_category("Section 3")
@export var section_3_label_1: Label
@export var section_3_label_1_duration: float = 3.0
@export var section_3_label_1_delay: float = 3.0

@export var section_3_label_2: Label
@export var section_3_label_2_duration: float = 3.0
@export var section_3_label_2_delay: float = 3.0

@export var section_3_label_3: Label
@export var section_3_label_3_duration: float = 3.0
@export var section_3_label_3_delay: float = 3.0

@export_category("Transitions")
@export var section_transition_delay: float = 5.0

@export_category("Default Responses")
@export var dr_label_1: Label
@export var dr_label_1_duration: float = 2.0

@export var dr_label_2: Label
@export var dr_label_2_duration: float = 2.0

@export var dr_label_3: Label
@export var dr_label_3_duration: float = 2.0

@export_category("Audio")
@export var speaking_sound: AudioStream
@export_range(-80, 24) var speaking_volume: float = 0.0

@onready var area = $Area2D
@onready var audio_player = $AudioStreamPlayer2D

var player_inside: bool = false
var current_section: int = 0
var is_playing: bool = false
var sections: Array = []
var default_responses: Array = []
var current_default_response: int = 0
var all_sections_completed: bool = false

func _ready():
	if not is_inside_tree():
		return
		
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
	# Setup audio player
	if audio_player and speaking_sound:
		audio_player.stream = speaking_sound
		audio_player.volume_db = speaking_volume
	
	# Build sections array
	for section_num in range(1, 4):
		var section_labels = []
		for label_num in range(1, 4):
			var label = get("section_" + str(section_num) + "_label_" + str(label_num))
			if label:
				label.visible = false
				section_labels.append({
					"label": label,
					"duration": get("section_" + str(section_num) + "_label_" + str(label_num) + "_duration"),
					"delay": get("section_" + str(section_num) + "_label_" + str(label_num) + "_delay")
				})
		if section_labels.size() > 0:
			sections.append(section_labels)
	
	# Build default responses array
	for i in range(1, 4):
		var label = get("dr_label_" + str(i))
		if label:
			label.visible = false
			default_responses.append({
				"label": label,
				"duration": get("dr_label_" + str(i) + "_duration")
			})

func _on_body_entered(body):
	if body is PlatformerController2D and not is_playing:
		player_inside = true
		
		if all_sections_completed and default_responses.size() > 0:
			_play_default_response()
		elif current_section < sections.size():
			_play_section()

func _on_body_exited(body):
	if body is PlatformerController2D:
		player_inside = false

func _play_section():
	if current_section >= sections.size():
		return
		
	is_playing = true
	var section = sections[current_section]
	
	# Start speaking sound
	if audio_player and speaking_sound:
		audio_player.play()
	
	# Play all labels in current section
	for i in range(section.size()):
		var data = section[i]
		data.label.visible = true
		
		await get_tree().create_timer(data.duration).timeout
		data.label.visible = false
		
		# Wait delay before next label (except after last one)
		if i < section.size() - 1:
			await get_tree().create_timer(data.delay).timeout
	
	# Stop speaking sound
	if audio_player:
		audio_player.stop()
	
	# Section finished
	current_section += 1
	
	# Check if all sections completed
	if current_section >= sections.size():
		all_sections_completed = true
	
	is_playing = false
	
	# If player still inside and more sections exist, wait transition delay then play next
	if player_inside and current_section < sections.size():
		await get_tree().create_timer(section_transition_delay).timeout
		if player_inside:
			_play_section()

func _play_default_response():
	if default_responses.size() == 0:
		return
		
	is_playing = true
	var response = default_responses[current_default_response]
	
	# Start speaking sound
	if audio_player and speaking_sound:
		audio_player.play()
	
	# IMPORTANT: Hide ALL default response labels first
	for dr in default_responses:
		dr.label.visible = false
		dr.label.size = Vector2.ZERO
	
	# Now show the current one
	response.label.visible = true
	
	await get_tree().create_timer(response.duration).timeout
	response.label.visible = false
	
	# Stop speaking sound
	if audio_player:
		audio_player.stop()
	
	# Cycle to next default response
	current_default_response = (current_default_response + 1) % default_responses.size()
	
	is_playing = false
