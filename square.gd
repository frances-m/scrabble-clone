extends Node2D

var TYPES: Dictionary = {
	"BS": { "color": "#fcdbae" },
	"SS": { "color": "#fcaeae" },
	"3W": { "color": "#e322e0" },
	"2W": { "color": "#fcaefb" },
	"3L": { "color": "#224fe3" },
	"2L": { "color": "#aecbfc" },
}

var type: String = "BS"
var row: int = 0
var col: int = 0
var mouse_over: bool = false

func _ready() -> void:
	set_color(TYPES[type]["color"])

func _process(_delta: float) -> void:
	if mouse_over && Input.is_action_just_released("left_click") && Globals.selected_tile:
		Globals.selected_tile.position = get_parent().position + position

func set_type(new_type: String) -> void:
	type = new_type

func set_grid_position(new_row: int, new_col: int) -> void:
	row = new_row
	col = new_col

func set_color(hex: String) -> void:
	%ColorRect.color = hex

func _on_area_2d_mouse_entered() -> void:
	mouse_over = true
	set_color("#a83232")

func _on_area_2d_mouse_exited() -> void:
	mouse_over = false
	set_color(TYPES[type]["color"])
