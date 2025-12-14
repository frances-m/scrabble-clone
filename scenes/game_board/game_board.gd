extends Node2D

var Square = preload("res://scenes/game_board/square/square.tscn")

var JSON_PATH: String = "res://config/squares.json"

func _ready() -> void:
	_place_squares()

func _place_squares() -> void:
	var board_data = _load_board_data()
	
	var start_pos: Vector2 = (position - %TextureRect.size) + Vector2(10.0, 30.0)
	var square_position: Vector2 = start_pos

	for i in range(0, board_data.size()):
		var row = board_data[i]

		for x in range(0, row.size()):
			var type = row[x]
			_place_square(type, square_position, i, x)
			square_position.x += Globals.tile_size + 10.0
		
		square_position.x = start_pos.x
		square_position.y += Globals.tile_size + 10.0

func _place_square(type: String, pos: Vector2, row: int, col: int) -> void:
	var square = Square.instantiate()
	
	square.position = pos
	square.set_type(type)
	square.set_grid_position(row, col)

	add_child(square)

func _load_board_data() -> Array:
	var json_file = FileAccess.get_file_as_string(JSON_PATH)
	return JSON.parse_string(json_file)
