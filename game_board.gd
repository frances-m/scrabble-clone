extends Node2D

var Square = preload("res://square.tscn")

var JSON_PATH: String = "res://squares.json"

func _ready() -> void:
	_place_squares()

func _place_squares() -> void:
	var board_data = _load_board_data()
	
	var start_pos: Vector2 = (position - %TextureRect.size) + Vector2(10.0, 30.0)
	var square_position: Vector2 = start_pos
	for row in board_data:
		for type in row:
			_place_square(type, square_position)
			square_position.x += Globals.tile_size + 10.0
		square_position.x = start_pos.x
		square_position.y += Globals.tile_size + 10.0

func _place_square(type: String, pos: Vector2) -> void:
	var square = Square.instantiate()
	square.position = pos
	square.set_type(type)
	add_child(square)

func _load_board_data() -> Array:
	var json_file = FileAccess.get_file_as_string(JSON_PATH)
	return JSON.parse_string(json_file)
