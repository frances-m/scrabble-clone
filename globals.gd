extends Node

signal change_player()

var turns_skipped: Dictionary = {
	1: 0,
	2: 0,
}

var current_player: int = 1

var tile_size: float = 54.0

var selected_tile

func switch_player(turn_skipped: bool = false) -> void:
	if !turn_skipped:
		turns_skipped[current_player] = 0

	current_player = 2 if current_player == 1 else 1
	emit_signal("change_player")

func skip_turn() -> void:
	turns_skipped[current_player] += 1

	# TODO: end game
	if turns_skipped[current_player] == 2:
		print("GAME OVER: TOO MANY TURNS SKIPPED")

	switch_player(true)
