extends Node2D

var MAX_TILES: int = 7
var LETTERS: Array = []
var TILE_GAP: float = 10.0
@onready var RACK_LENGTH: float = %CollisionShape2D.shape.size.x
@onready var RACK_HEIGHT: float = %CollisionShape2D.shape.size.y

var tiles: Array = []

func _ready() -> void:
	draw_tiles()

func draw_tiles() -> void:
	var tiles_to_draw: int = MAX_TILES - tiles.size()
	for i in tiles_to_draw:
		draw_tile()

func draw_tile() -> void:
	var tile = TileBag.draw_tile()
	tiles.append(tile)
	
	position_tiles()
	
	add_sibling.call_deferred(tile)
	
func position_tiles() -> void:
	var tile_count: int = tiles.size()
	
	var tiles_length: float = Globals.tile_size * tile_count
	tiles_length += TILE_GAP * (tile_count - 1)
	
	var global_pos = to_global(%CollisionShape2D.position)
	
	var x: float = global_pos.x - tiles_length / 2 + Globals.tile_size / 2
	var y: float = global_pos.y - 40.0
	var tile_position: Vector2 = Vector2(x, y)
	
	
	for tile in tiles:
		tile.position = tile_position
		tile_position.x += Globals.tile_size + TILE_GAP
