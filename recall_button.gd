extends Node2D

signal clicked()

func _on_button_button_up() -> void:
	emit_signal("clicked")
