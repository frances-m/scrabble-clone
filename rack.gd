extends Node2D

var MAX_TILES: int = 7
var LETTERS: Array = []
var TILE_GAP: float = 10.0

var tiles: Array = []

@onready var player: int = get_meta("player", 0)

func _ready() -> void:
	if player == 1:
		draw_tiles()
	else:
		visible = false
	BoardState.connect("tiles_scored", Callable(self, "_on_tiles_scored"))

func draw_tiles() -> void:
	var tiles_to_draw: int = MAX_TILES - tiles.size()
	for i in tiles_to_draw:
		draw_tile()

func draw_tile() -> void:
	var tile = TileBag.draw_tile()
	tiles.append(tile)
	
	position_tiles()
	
	tile.connect("finished_moving", Callable(self, "_on_tile_finished_moving"))
	
	add_sibling.call_deferred(tile)
	
func position_tiles() -> void:
	var tile_count: int = tiles.size()
	
	var tiles_length: float = Globals.tile_size * tile_count
	tiles_length += TILE_GAP * (tile_count - 1)
	
	var global_pos = to_global(%CollisionShape2D.position)
	
	var x: float = global_pos.x - tiles_length / 2 + Globals.tile_size / 2
	var y: float = global_pos.y - 20.0
	var tile_position: Vector2 = Vector2(x, y)
	
	for tile in tiles:
		tile.position = tile_position
		tile_position.x += Globals.tile_size + TILE_GAP

func _on_tiles_scored() -> void:
	var is_player_turn: bool = Globals.current_player == player
	visible = is_player_turn
	for tile in tiles:
		tile.visible = is_player_turn
	if is_player_turn:
		draw_tiles()

func _on_tile_finished_moving(tile: Sprite2D, placed: bool) -> void:
	if placed:
		var idx = tiles.find(tile)
		tiles.pop_at(idx)
	elif tiles.find(tile) == -1 && tiles.size() < MAX_TILES:
		tiles.append(tile)
	
	position_tiles()
