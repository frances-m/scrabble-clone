extends Node2D

var TYPES: Dictionary = {
	"BS": { "color": "#fcdbae" },
	"SS": { "color": "#fcaeae" },
	"3W": { "color": "#e322e0", "mult": 3, "type": "word" },
	"2W": { "color": "#fcaefb", "mult": 2, "type": "word" },
	"3L": { "color": "#224fe3", "mult": 3, "type": "letter" },
	"2L": { "color": "#aecbfc", "mult": 2, "type": "letter" },
}

var type: String = "BS"
var row: int = 0
var col: int = 0
var mouse_over: bool = false

func _ready() -> void:
	set_color()

func _process(_delta: float) -> void:
	var selected_tile = Globals.selected_tile
	if mouse_over && Input.is_action_just_released("left_click") && selected_tile:
		selected_tile.position = get_parent().position + position
		selected_tile.placed = true
		BoardState.place_tile(selected_tile, self)
		

func set_type(new_type: String) -> void:
	type = new_type

func set_grid_position(new_row: int, new_col: int) -> void:
	row = new_row
	col = new_col

func set_color(color: Color = get_color()) -> void:
	%ColorRect.color = color

func get_mult_type() -> String:
	if !TYPES[type].has("type"):
		return ""
	return TYPES[type]["type"]

func get_mult() -> int:
	if !TYPES[type].has("mult"):
		return 1
	return TYPES[type]["mult"]

func get_color() -> Color:
	return Color.html(TYPES[type]["color"])

func _on_area_2d_mouse_entered() -> void:
	mouse_over = true
	var color = get_color().lightened(0.4)
	set_color(color)

func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
	set_color()
	
