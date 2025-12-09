extends Label

func _ready():
	text = "Score: %d" % GameManager.score
