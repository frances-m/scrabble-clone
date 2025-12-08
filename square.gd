extends Node2D

var TYPES: Dictionary = {
	"BS": { "color": "#000000" },
	"SS": { "color": "#111111" },
	"3W": { "color": "#222222" },
	"2W": { "color": "#333333" },
	"3L": { "color": "#444444" },
	"2L": { "color": "#555555" },
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
