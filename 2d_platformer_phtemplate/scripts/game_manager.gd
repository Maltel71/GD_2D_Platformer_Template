extends Node

var score: int = 0

signal score_changed(new_score)

func add_score(points: int):
	score += points
	score_changed.emit(score)
