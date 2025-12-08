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

func _ready() -> void:
	set_color(TYPES[type]["color"])
	
func set_type(new_type: String) -> void:
	type = new_type

func set_color(hex: String) -> void:
	%ColorRect.color = hex

func _on_area_2d_mouse_entered() -> void:
	set_color("#a83232")

func _on_area_2d_mouse_exited() -> void:
	set_color(TYPES[type]["color"])
