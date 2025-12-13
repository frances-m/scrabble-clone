extends Control

var player: int = 0

func _ready() -> void:
	Scorer.connect("score_updated", Callable(self, "update_score"))

func get_player() -> int:
	return get_meta("player", 0)

func update_score() -> void:
	var score = Scorer.player_scores[get_player()]
	%Label.text = str(score)
