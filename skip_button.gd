extends Node2D

signal clicked()

func _on_button_pressed() -> void:
	emit_signal("clicked")
	Globals.skip_turn()
