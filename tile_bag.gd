extends Node

var Tile = preload("res://tile_sprite.tscn")

var JSON_PATH: String = "res://tile_bag.json"

var tile_bag: Array[Sprite2D] = []

func _ready() -> void:
	_init_tiles()

func draw_tile() -> Sprite2D:
	var tile_idx = randi_range(0, tile_bag.size() - 1)
	return tile_bag.pop_at(tile_idx)

func return_tile(tile: Sprite2D) -> void:
	tile_bag.append(tile)

func _init_tiles() -> void:
	var tile_data: Array = _load_tile_data()
	for tile in tile_data:
		_create_tiles(tile)

func _create_tiles(tile_data) -> void:
	for i in tile_data.count:
		var tile = Tile.instantiate()
		tile.set_tile_letter(tile_data.letter)
		tile.set_value(tile_data.value)
		tile_bag.append(tile)
	
func _load_tile_data() -> Array:
	var json_file = FileAccess.get_file_as_string(JSON_PATH)
	return JSON.parse_string(json_file)
