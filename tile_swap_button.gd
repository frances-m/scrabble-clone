extends Sprite2D

var TILE: Sprite2D = null

var selected: bool = false

signal clicked(tile: Sprite2D, is_selected: bool)

func set_tile(tile: Sprite2D) -> void:
	TILE = tile
	%Letter.text = tile.get_tile_letter()

func _toggle_selected() -> void:
	selected = !selected
	_update_color()

func _update_color() -> void:
	var color = Color.html("#c4a695")
	if selected:
		%ColorRect.color = color.lightened(0.8)
		return
	
	%ColorRect.color = color

func _on_button_up() -> void:
	_toggle_selected()
	
	emit_signal("clicked", TILE, selected)
