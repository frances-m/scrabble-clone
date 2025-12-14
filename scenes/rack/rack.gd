extends Node2D

var MAX_TILES: int = 7
var LETTERS: Array = []
var TILE_GAP: float = 10.0

var tiles: Array[Sprite2D] = []

var SwapSelector = preload("res://scenes/swap_selection/swap_selection.tscn")

@onready var player: int = get_meta("player", 0)
@onready var recall_button: Node2D = get_parent().get_node("%RecallButton")
@onready var skip_button: Node2D = get_parent().get_node("%SkipButton")
@onready var swap_button: Node2D = get_parent().get_node("%SwapButton")

func _ready() -> void:
	_on_player_change()
	_init_listeners()

func _init_listeners() -> void:
	Globals.connect("change_player", Callable(self, "_on_player_change"))
	recall_button.connect("clicked", Callable(self, "_recall_tiles"))
	skip_button.connect("clicked", Callable(self, "_recall_tiles"))
	swap_button.connect("clicked", Callable(self, "_swap_tiles"))

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

func _disable() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	for tile in tiles:
		tile.visible = false
		tile.process_mode = Node.PROCESS_MODE_DISABLED

func _enable() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	visible = true
	for tile in tiles:
		tile.process_mode = Node.PROCESS_MODE_INHERIT
		tile.visible = true

func _on_player_change() -> void:
	if Globals.current_player == player:
		_enable()
		draw_tiles()
	else: 
		_disable()

func _on_tile_finished_moving(tile: Sprite2D, placed: bool) -> void:
	if placed:
		var idx = tiles.find(tile)
		if idx != -1:
			tiles.pop_at(idx)
	elif tiles.find(tile) == -1 && tiles.size() < MAX_TILES:
		tiles.append(tile)
	
	position_tiles()

func _recall_tiles() -> void:
	if Globals.current_player != player:
		return

	var placed_tiles = BoardState.remove_all_from_pending()
	for tile in placed_tiles:
		tiles.append(tile)

	position_tiles()

func _swap_tiles() -> void:
	if Globals.current_player != player:
		return
	
	_recall_tiles()

	var swap_selector = SwapSelector.instantiate()
	swap_selector.initialize(tiles)
	swap_selector.connect("tiles_selected", Callable(self, "_swap_selected_tiles"))
	get_parent().add_sibling(swap_selector)

func _swap_selected_tiles(selected_tiles: Array[Sprite2D]) -> void:
	for selected_tile in selected_tiles:
		var idx = tiles.find(selected_tile)
		tiles.pop_at(idx)
		selected_tile.disconnect_signals()
		get_parent().remove_child(selected_tile)
		TileBag.return_tile(selected_tile)
	Globals.switch_player()
