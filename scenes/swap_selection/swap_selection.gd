extends Control

var TILE_GAP: int = 10

var TileButton = preload("res://scenes/swap_selection/tile_swap_button/tile_swap_button.tscn")

var tiles: Array[Sprite2D] = []
var selected_tiles: Array[Sprite2D] = []

signal tiles_selected(selected: Array[Sprite2D])

func initialize(current_tiles: Array[Sprite2D]) -> void:
	tiles = current_tiles
	_render_buttons()

func _render_buttons() -> void:
	var height = Globals.tile_size
	var width = (Globals.tile_size + TILE_GAP) * tiles.size() - TILE_GAP
	
	var initialX = %ColorRect.size.x / 2 - width / 2
	var initialY = %ColorRect.size.y / 2 - height / 1.5
	
	var x = initialX
	var y = initialY
	
	for tile in tiles:
		var button = TileButton.instantiate()
		button.set_tile(tile)
		button.connect("clicked", Callable(self, "_on_tile_select"))
		button.position = Vector2(x, y)
		
		add_child.call_deferred(button)
		
		x += Globals.tile_size + TILE_GAP

func _on_tile_select(tile: Sprite2D, selected: bool) -> void:
	if selected:
		selected_tiles.append(tile)
		return
	
	var idx = selected_tiles.find(tile)
	selected_tiles.pop_at(idx)

func _on_confirm_button_pressed() -> void:
	emit_signal("tiles_selected", selected_tiles)
	queue_free()

func _on_cancel_button_pressed() -> void:
	queue_free()
