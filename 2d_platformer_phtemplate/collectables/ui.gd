extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var health_label = $HealthLabel

func _ready():
	GameManager.score_changed.connect(_on_score_changed)
	_update_score_display()

func _process(_delta):
	# Update health display every frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		health_label.text = "Health: %d" % player.current_health

func _on_score_changed(_new_score):
	_update_score_display()

func _update_score_display():
	score_label.text = "Score: %d" % GameManager.score
