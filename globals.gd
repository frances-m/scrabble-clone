extends Node

var current_player: int = 1

var tile_size: float = 54.0

var selected_tile

func switch_player() -> void:
	current_player = 2 if current_player == 1 else 1
