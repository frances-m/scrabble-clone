extends Control

var TILE_GAP: int = 10
var ROW_LENGTH: int = 6
var LETTERS: Array[String] = [
	"A", "B", "C", "D", "E", "F",
	"G", "H", "I", "J", "K", "L",
	"M", "N", "O", "P", "Q", "R",
	"S", "T", "U", "V", "W", "X",
	"Y", "Z"
]

var TileButton = preload("res://tile_button.tscn")

var tile: Sprite2D = null

func initialize(blank_tile: Sprite2D) -> void:
	tile = blank_tile
	_render_buttons()

func _render_buttons() -> void:
	var rows: int = ceil(LETTERS.size() / float(ROW_LENGTH))
	var height = (Globals.tile_size + TILE_GAP) * rows - TILE_GAP
	var width = (Globals.tile_size + TILE_GAP) * ROW_LENGTH - TILE_GAP
	
	var initialX = %ColorRect.size.x / 2 - width / 2
	var initialY = %ColorRect.size.y / 2 - height / 1.5
	
	var x = initialX
	var y = initialY
	
	for letter in LETTERS:
		var letter_idx = LETTERS.find(letter)
		if letter_idx % ROW_LENGTH == 0:
			y += Globals.tile_size + TILE_GAP
			x = initialX
		var button = TileButton.instantiate()
		button.set_letter(letter)
		button.connect("clicked", Callable(self, "_on_letter_select"))
		button.position = Vector2(x, y)
		
		add_child.call_deferred(button)
		
		x += Globals.tile_size + TILE_GAP

func _on_letter_select(letter: String) -> void:
	tile.set_tile_letter(letter)
	tile.update_display()
	queue_free()
