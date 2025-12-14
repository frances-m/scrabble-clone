extends Node

var first_move: bool = true;

var player_scores: Dictionary = {
	1: 0,
	2: 0,
}

@onready var WORD_LIST = load_word_list()

signal score_updated()
signal word_played(word: String, word_score: int)

func run(pending_tiles: Array) -> bool:
	var score_calculator: ScoreCalculator = ScoreCalculator.new(pending_tiles)

	var errors: Array = score_calculator.get_errors()
	if errors.size():
		for error in errors:
			print(error)
		return false

	var word = score_calculator.get_word()
	var word_score = score_calculator.get_score()
	var player = Globals.current_player
	player_scores[player] += word_score

	emit_signal("word_played", word, word_score)
	emit_signal("score_updated")
	first_move = false

	return true

func load_word_list() -> Array:
	var path = "res://words.txt"
	var words = FileAccess.get_file_as_string(path)
	return words.split("\n")

class ScoreCalculator:
	var tiles: Array = []
	var parallel_axis: String = ""

	#validation flags
	var has_gap: bool = false
	var touches_existing_tile: bool = false
	var on_starting_square: bool = false
	var errors: Array = []

	# score 
	var letters: Array = []
	var perpendicular_words: Array = []
	var score_tally: int = 0
	var word_multiplier: int = 0
	var final_score: int = 0

	func _init(pending_tiles: Array) -> void:
		tiles = pending_tiles
		calculate_score()

	func calculate_score() -> void:
		validate_length()
		calculate_word_direction()
		sort_tiles()
		score_tiles()
		validate_word()
		calculate_final_score()
	
	func get_word() -> String:
		return "".join(letters)

	func get_score() -> int:
		return final_score
	
	func get_mult() -> int:
		return word_multiplier if word_multiplier > 0 else 1
	
	func get_errors() -> Array:
		return errors
	
	func has_errors() -> bool:
		return errors.size()

	func validate_length() -> void:
		if tiles.size() < 1:
			errors.append("NO TILES")
	
	func is_vertical() -> bool:
		return parallel_axis == "col"
	
	func is_horizontal() -> bool:
		return !is_vertical()
	
	func perpendicular_axis() -> String:
		return "row" if parallel_axis == "col" else "col"

	func calculate_word_direction() -> void:
		if has_errors():
			return

		var compare_row = tiles[0].square.row
		var compare_col = tiles[0].square.col
		
		var share_row = tiles.all(func(tile): return tile.square.row == compare_row)
		var share_col = tiles.all(func(tile): return tile.square.col == compare_col)
		
		if !share_row && !share_col:
			errors.append("NO SHARED ROW OR COL")
		
		parallel_axis = "row" if share_row else "col"

	func calculate_final_score() -> void:
		if final_score:
			return

		final_score = score_tally * get_mult()

		for word in perpendicular_words:
			final_score += word.score * word.mult

		if tiles.size() == 7:
			final_score += 50

	func sort_tiles() -> void:
		if has_errors():
			return
		tiles.sort_custom(func(a, b): return a.square[perpendicular_axis()] < b.square[perpendicular_axis()])

	func score_tiles() -> void:
		if has_errors():
			return

		var tiles_in_front = get_tiles_in_front(tiles[0])
		score_existing_parallel_tiles(tiles_in_front)

		var last_tile_pos: int = -1
		for tile in tiles:
			score_tiles_between(last_tile_pos, tile)
			score_tile(tile)
			score_perpendicular_tiles(tile)
			last_tile_pos = tile.square[perpendicular_axis()]
			
			if tile.square.type == "SS":
				on_starting_square = true

		var tiles_behind = get_tiles_behind(tiles[-1])
		score_existing_parallel_tiles(tiles_behind)

	func score_tile(tile: Sprite2D) -> void:
		letters.append(tile.get_tile_letter())

		var tile_value = tile.get_value()
		if tile.square.get_mult_type() == "word":
			word_multiplier += tile.square.get_mult()
		if tile.square.get_mult_type() == "letter":
			tile_value *= tile.square.get_mult()
		score_tally += tile_value
	
	func score_tiles_between(last_tile_pos, tile) -> void:
		var tile_pos = tile.square[perpendicular_axis()]
		if last_tile_pos == -1 or tile_pos == last_tile_pos + 1:
			return

		for i in range(last_tile_pos + 1, tile_pos):
			var existing_tile = get_existing_parallel_tile(i, tile.square)
			if !existing_tile:
				errors.append("GAP BETWEEN TILES")
				break
			else:
				touches_existing_tile = true
				letters.append(existing_tile.get_tile_letter())
				score_tally += existing_tile.get_value()
	
	func score_perpendicular_tiles(placed_tile: Sprite2D) -> void:
		var tiles_above = get_tiles_in_front(placed_tile, false, parallel_axis)
		var tiles_below = get_tiles_behind(placed_tile, false, parallel_axis)
		if tiles_above.size() or tiles_below.size():
			var square = placed_tile.square
			var mult = square.get_mult() if square.get_mult_type() == "word" else 1
			var word = {
				"mult": mult,
				"letters": [],
				"score": 0
			}
			score_existing_perpendicular_tiles(tiles_above, word)
			word.letters.append(placed_tile.get_tile_letter())
			score_existing_perpendicular_tiles(tiles_below, word)
			perpendicular_words.append(word)
	
	func get_tiles_in_front(tile: Sprite2D, parallel: bool = true, axis = perpendicular_axis()) -> Array:
		var tile_pos = tile.square[axis]
		var rnge = range(tile_pos - 1, -1, -1)
		return get_tiles_adjacent_to(tile, rnge, parallel, false)
	
	func get_tiles_behind(tile: Sprite2D, parallel: bool = true, axis = perpendicular_axis()) -> Array:
		var tile_pos = tile.square[axis]
		var rnge = range(tile_pos + 1, 15, 1)
		return get_tiles_adjacent_to(tile, rnge, parallel)
	
	func get_tiles_adjacent_to(tile: Sprite2D, rnge, parallel: bool = true, after: bool = true) -> Array:
		var adjacent_tiles = []
		for i in rnge:
			var existing_tile
			if parallel:
				existing_tile = get_existing_parallel_tile(i, tile.square)
			else:
				existing_tile = get_existing_perpendicular_tile(i, tile.square)
			if !existing_tile:
				break
			touches_existing_tile = true
			adjacent_tiles.push_front(existing_tile)

		if after:
			adjacent_tiles.reverse()

		return adjacent_tiles
	
	func get_existing_perpendicular_tile(pos: int, tile_pos: Node2D) -> Sprite2D:
		var row: int = pos if is_horizontal() else tile_pos.row
		var col: int = pos if is_vertical() else tile_pos.col
		return BoardState.get_tile_at(row, col)

	func get_existing_parallel_tile(pos: int, tile_pos: Node2D) -> Sprite2D:
		var row: int = pos if is_vertical() else tile_pos.row
		var col: int = pos if is_horizontal() else tile_pos.col
		return BoardState.get_tile_at(row, col)

	func score_existing_parallel_tiles(existing_tiles: Array) -> void:
		for tile in existing_tiles:
			letters.append(tile.get_tile_letter())
			score_tally += tile.get_value()

	func score_existing_perpendicular_tiles(existing_tiles: Array, word: Dictionary) -> void:
		for tile in existing_tiles:
			word.score += tile.get_value()
			word.letters.append(tile.get_tile_letter())

	func validate_word() -> void:
		if has_errors():
			return

		if Scorer.first_move && !on_starting_square:
			errors.append("FIRST MOVE NEEDS TO BE ON STARTING SQUARE")
	
		if !Scorer.first_move && !touches_existing_tile:
			errors.append("NOT ADJACENT TO ANY EXISTING TILES")
		
		if has_gap:
			errors.append("GAP BETWEEN TILES")
	
		var word = "".join(letters)
		if !is_valid_word(word):
			errors.append("INVALID WORD: " + word)
		
		for perpendicular_word in perpendicular_words:
			if !is_valid_word("".join(perpendicular_word.letters)):
				errors.append("INVALID WORD: " + perpendicular_word)

	func is_valid_word(word: String) -> bool:
		return Scorer.WORD_LIST.has(word)
