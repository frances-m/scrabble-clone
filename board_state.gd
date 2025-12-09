extends Node

var board: Array = []
var pending_tiles: Array = []

signal tiles_scored()

func _ready() -> void:
	initialize_board()

func get_tile_at(row: int, col: int) -> Sprite2D:
	return board[row][col]

func place_tile(tile: Sprite2D, square: Node2D) -> void:
	pending_tiles.append({
		"tile": tile,
		"row": square.row,
		"col": square.col,
	})
	tile.square = square
	square.tile = tile
	tile.connect("started_moving", Callable(self, "_remove_from_pending"))

func _remove_from_pending(tile: Sprite2D) -> void:
	tile.disconnect("started_moving", Callable(self, "_remove_from_pending"))
	tile.square.tile = null
	tile.square = null
	var idx = pending_tiles.find_custom(func(t): return t["tile"] == tile)
	if idx == -1:
		return
	pending_tiles.pop_at(idx)

func score_pending() -> void:
	var scored: bool = Scorer.score(pending_tiles)
	
	if !scored:
		return
	
	for tile in pending_tiles:
		var row = tile["row"]
		var col = tile["col"]
		board[row][col] = tile["tile"]
		tile["tile"].disconnect("started_moving", Callable(self, "_remove_from_pending"))
		tile["tile"].scored = true
	
	pending_tiles = []
	emit_signal("tiles_scored")

func initialize_board() -> void:
	for i in range(0, 15):
		board.append([])
		for x in range(0, 15):
			board[i].append(null)
