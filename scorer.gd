extends Node

var player1_score: int = 0;
var player2_score: int = 0;

@onready var WORD_LIST = load_word_list()

func score(pending_tiles: Array) -> bool:
	if pending_tiles.size() < 1:
		return false
	
	var row = pending_tiles[0]["row"]
	var col = pending_tiles[0]["col"]
	
	var share_row = pending_tiles.all(func(tile): return tile["row"] == row)
	var share_col = pending_tiles.all(func(tile): return tile["col"] == col)
	
	if !share_row && !share_col:
		return false
	
	var sort_along = "row" if share_row else "col"
	pending_tiles.sort_custom(func(a, b): return a[sort_along] > b[sort_along])
	
	var letters = []
	var has_gap = false
	var word_multiplier = 1
	var score_tally = 0
	
	for t in pending_tiles:
		var tile = t["tile"]
		letters.append(tile.get_tile_letter())
		var tile_value = tile.get_value()
		if tile.square.get_mult_type() == "word":
			word_multiplier += tile.square.get_mult()
		if tile.square.get_mult_type() == "letter":
			tile_value *= tile.square.get_mult()
		score_tally += tile_value
	
	score_tally *= word_multiplier
	
	if has_gap:
		return false
	
	var word = "".join(letters)
	if !is_valid_word(word):
		return false
	
	print(score_tally)
	return true

func is_valid_word(word: String) -> bool:
	return WORD_LIST.has(word)

func load_word_list() -> Array:
	var path = "res://words.txt"
	var words = FileAccess.get_file_as_string(path)
	return words.split("\n")
