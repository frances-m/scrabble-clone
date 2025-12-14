extends Sprite2D

var LETTER: String = ""

signal clicked()

func set_letter(letter: String):
	LETTER = letter
	%Letter.text = letter

func _on_button_up() -> void:
	emit_signal("clicked", LETTER)
