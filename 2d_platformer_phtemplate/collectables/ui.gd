extends CanvasLayer

@onready var score_label = $ScoreLabel

func _ready():
	GameManager.score_changed.connect(_on_score_changed)
	_update_score_display()

func _on_score_changed(_new_score):
	_update_score_display()

func _update_score_display():
	score_label.text = "Score: %d" % GameManager.score
