extends Control

func _ready() -> void:
	Scorer.connect("score_updated", Callable(self, "update_score"))

func get_player() -> int:
	return get_meta("player", 0)

func update_score(player: int, score: int) -> void:
	if get_player() == player:
		%Label.text = str(score)
