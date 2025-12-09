extends Node

var first_move: bool = true;

var player_scores: Dictionary = {
	1: 0,
	2: 0,
}

@onready var WORD_LIST = load_word_list()

signal score_updated()

func score(pending_tiles: Array) -> bool:
	if pending_tiles.size() < 1:
		return false
	
	var compare_row = pending_tiles[0]["row"]
	var compare_col = pending_tiles[0]["col"]
	print("COMPARE ROW ", compare_row)
	print("COMPARE COL ", compare_col)
	
	var share_row = pending_tiles.all(func(tile): return tile["row"] == compare_row)
	var share_col = pending_tiles.all(func(tile): return tile["col"] == compare_col)
	
	print("SHARE ROW ", share_row)
	print("SHARE COL ", share_col)
	if !share_row && !share_col:
		return false
	
	var axis = "row" if share_row else "col"
	print("SORT AXIS ", axis)
	pending_tiles.sort_custom(func(a, b): return a[axis] > b[axis])
	
	var letters = []
	var has_gap = false
	var word_multiplier = 1
	var score_tally = 0
	var on_starting_square = false
	var pos_axis: String = "row" if axis == "col" else "col"
	var pos: int = 0
	
	print("POS AXIS ", pos_axis)
	
	for t in pending_tiles:
		var tile = t["tile"]
		
		if pos && t[pos_axis] != pos + 1:
			print(range(pos + 1, t[pos_axis]))
			for i in range(pos + 1, t[pos_axis]):
				var x = i if pos_axis == "row" else t["row"]
				var y = i if pos_axis == "col" else t["col"]
				print("x: ", x, " y: ", y)
				var scored_tile = BoardState.get_tile_at(x, y)
				print(scored_tile)
				if !scored_tile:
					has_gap = true
				else:
					print(scored_tile.get_tile_letter())
					letters.append(scored_tile.get_tile_letter())
					score_tally += scored_tile.get_value()
		
		pos = t[pos_axis]
		
		# flag if on start square
		if tile.square.type == "SS":
			on_starting_square = true

		# calculate score
		letters.append(tile.get_tile_letter())
		var tile_value = tile.get_value()
		if tile.square.get_mult_type() == "word":
			word_multiplier += tile.square.get_mult()
		if tile.square.get_mult_type() == "letter":
			tile_value *= tile.square.get_mult()
		score_tally += tile_value
	
	score_tally *= word_multiplier
	
	if first_move && !on_starting_square:
		return false
	
	if has_gap:
		return false
	
	var word = "".join(letters)
	if !is_valid_word(word):
		return false
	
	var player = Globals.current_player
	player_scores[player] += score_tally
	
	emit_signal("score_updated")
	
	first_move = false
	
	return true

func is_valid_word(word: String) -> bool:
	return WORD_LIST.has(word)

func load_word_list() -> Array:
	var path = "res://words.txt"
	var words = FileAccess.get_file_as_string(path)
	return words.split("\n")
