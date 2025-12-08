extends Node2D

var Square = preload("res://square.tscn")

var JSON_PATH: String = "res://squares.json"

# TODO: not currently using this
var board_squares: Array = []

func _ready() -> void:
	_setup_grid()
	_place_squares()

func _setup_grid() -> void:
	for i in range(0, 15):
		board_squares.append([])
		for x in range(0, 15):
			board_squares[i].append(null)

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
	board_squares[row][col] = square
	
	square.position = pos
	square.set_type(type)
	square.set_grid_position(row, col)

	add_child(square)

func _load_board_data() -> Array:
	var json_file = FileAccess.get_file_as_string(JSON_PATH)
	return JSON.parse_string(json_file)
